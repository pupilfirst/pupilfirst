module Discord
  class SyncProfileService
    attr_reader :error_msg
    def initialize(user, additional_discord_role_ids: nil)
      @user = user
      @additional_discord_role_ids =
        if additional_discord_role_ids.is_a?(Array)
          additional_discord_role_ids
        else
          [additional_discord_role_ids].compact
        end.map(&:to_s)

      @error_msg = ""
    end

    def execute
      return false unless sync_ready?

      rest_client =
        Discordrb::API::Server.update_member(
          "Bot #{configuration.bot_token}",
          configuration.server_id,
          user.discord_user_id,
          roles: all_discord_role_ids,
          nick: nick_name
        )

      if rest_client.code == 200
        sync_and_cache_roles(rest_client)
        true
      else
        false
      end
    rescue Discordrb::Errors::UnknownMember
      message =
        t("unknown_member", variables: { member_id: user.discord_user_id })
      Rails.logger.error(message)
      @user.update!(discord_user_id: nil)

      error(message)
    rescue Discordrb::Errors::NoPermission
      message =
        t("no_permission", variables: { member_id: user.discord_user_id })
      Rails.logger.error(message)

      error(message)
    rescue RestClient::BadRequest => e
      message =
        t(
          "bad_request",
          variables: {
            member_id: user.discord_user_id,
            error: e.response.body
          }
        )
      Rails.logger.error(message)

      error(message)
    end

    def sync_ready?
      user.discord_user_id.present? && configuration.configured?
    end

    private

    attr_reader :user, :additional_discord_role_ids

    def t(key, variables = {})
      I18n.t("services.discord.sync_profile_service.#{key}", **variables)
    end

    def sync_and_cache_roles(rest_client)
      response_role_ids = JSON.parse(rest_client.body).dig("roles")

      additional_synced_role_ids = additional_role_ids & response_role_ids

      school
        .discord_roles
        .where(discord_id: additional_synced_role_ids)
        .each do |role|
          AdditionalUserDiscordRole.where(
            user_id: user.id,
            discord_role_id: role.id
          ).first_or_create!
        end

      deleted_discord_role_ids =
        user
          .discord_roles
          .where.not(discord_id: additional_synced_role_ids)
          .pluck(:id)

      AdditionalUserDiscordRole
        .where(discord_role_id: deleted_discord_role_ids)
        .where(user_id: user.id)
        .delete_all
    end

    def all_discord_role_ids
      @all_discord_role_ids ||=
        begin
          cohort_assigned_ids = [
            user.cohorts.pluck(:discord_role_ids),
            configuration.default_role_ids
          ].flatten.compact.uniq

          (additional_role_ids + cohort_assigned_ids).uniq
        end
    end

    def additional_role_ids
      @additional_role_ids ||=
        school_discord_roles
          .filter { |role| role.id.to_s.in?(additional_discord_role_ids) }
          .pluck(:discord_id)
    end

    def configuration
      @configuration ||= Schools::Configuration::Discord.new(school)
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

    def error(message)
      @error_msg = message
      false
    end
  end
end
