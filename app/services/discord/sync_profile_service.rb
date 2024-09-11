module Discord
  class SyncProfileService
    attr_reader :warning_msg

    def initialize(user, additional_discord_role_ids: nil)
      @user = user
      @additional_discord_role_ids =
        if additional_discord_role_ids.is_a?(Array)
          additional_discord_role_ids
        else
          [additional_discord_role_ids].compact
        end.map(&:to_s)

      @warning_msg = ""
    end

    def execute
      if @user.discord_user_id.blank?
        raise SyncError.new(t("user_account_not_connected"))
      end

      data = make_api_request
      sync_and_cache_roles(data)
    rescue Discordrb::Errors::UnknownMember
      raise_sync_error(:unknown_member)
      @user.update!(discord_user_id: nil)
    rescue Discordrb::Errors::NoPermission
      raise_sync_error(:no_permission)
    rescue RestClient::BadRequest => e
      raise_sync_error(:bad_request, err: e)
    end

    def raise_sync_error(type, err: nil)
      message =
        case type
        when :unknown_member
          t("unknown_member", member_id: @user.discord_user_id)
        when :no_permission
          t("no_permission", member_id: @user.discord_user_id)
        when :bad_request
          t(
            "bad_request",
            member_id: @user.discord_user_id,
            error: err.response.body
          )
        end

      Rails.logger.error(message)
      raise SyncError.new(message)
    end

    def make_api_request
      rest_client =
        Discordrb::API::Server.update_member(
          "Bot #{configuration.bot_token}",
          configuration.server_id,
          @user.discord_user_id,
          roles: all_discord_role_ids,
          nick: nick_name
        )

      unless rest_client.code == 200
        raise SyncError.new(t("error_while_syncing"))
      end

      JSON.parse(rest_client.body)
    end

    private

    def t(key, variables = {})
      I18n.t("services.discord.sync_profile_service.#{key}", **variables)
    end

    def sync_and_cache_roles(data)
      response_role_ids = data["roles"]

      additional_synced_role_ids = additional_role_ids & response_role_ids

      @warning_msg = t("sync_warning") if (
        additional_role_ids - additional_synced_role_ids
      ).present?

      school
        .discord_roles
        .where(discord_id: additional_synced_role_ids)
        .each do |role|
          AdditionalUserDiscordRole.where(
            user_id: @user.id,
            discord_role_id: role.id
          ).first_or_create!
        end

      deleted_discord_role_ids =
        @user
          .discord_roles
          .where.not(discord_id: additional_synced_role_ids)
          .pluck(:id)

      AdditionalUserDiscordRole
        .where(discord_role_id: deleted_discord_role_ids)
        .where(user_id: @user.id)
        .delete_all
    end

    def all_discord_role_ids
      @all_discord_role_ids ||=
        begin
          cohort_assigned_ids = [
            @user.cohorts.pluck(:discord_role_ids),
            school.default_discord_role_ids
          ].flatten.compact.uniq

          (additional_role_ids + cohort_assigned_ids).uniq
        end
    end

    def additional_role_ids
      @additional_role_ids ||=
        school_discord_roles
          .filter { |role| role.id.to_s.in?(@additional_discord_role_ids) }
          .pluck(:discord_id)
    end

    def configuration
      @configuration ||=
        begin
          config = Schools::Configuration::Discord.new(school)

          unless config.configured?
            raise SyncError.new(t("discord_not_configured"))
          end

          config
        end
    end

    def nick_name
      return @user.name if @user.name.length <= 32
      @user.name[0..28] + "..."
    end

    def school_discord_roles
      @school_discord_roles ||= school.discord_roles.to_a
    end

    def school
      @school ||= @user.school
    end

    class SyncError < StandardError
    end
  end
end
