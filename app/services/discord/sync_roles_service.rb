module Discord
  class SyncRolesService
    def initialize(school:)
      @school = school
    end

    def save
      deleted_discord_roles =
        discord_roles.where.not(discord_id: discord_server_roles.pluck(:id))

      discord_server_roles.each do |sr|
        # Every user has @everyone role, there is no point in storing it.
        next if sr.name.eql?("@everyone")

        role =
          DiscordRole.find_or_initialize_by(
            school_id: @school.id,
            discord_id: sr.id
          )

        # Skip any roles which is above bot role in Discord Role hierarchy.
        # Currently, roles which have moved up and crossed the Bot's role those roles are being updated.
        next if sr.position >= bot_position && role.new_record?

        role.update!(
          name: sr.name,
          position: sr.position,
          color_hex: sr.color_hex,
          data: sr.data
        )
      end

      deleted_discord_roles.each(&:destroy)
    end

    def deleted_roles?
      # Check if there is any role which is cached but is not present on Discord.
      discord_roles
        .where.not(discord_id: discord_server_roles.pluck(:id))
        .exists?
    end

    # Returns roles that are cached/saved in the DB.
    def cached_roles
      @cached_roles ||=
        begin
          server_discord_role_ids = discord_server_roles.pluck(:id)
          discord_roles.map do |role|
            OpenStruct.new(
              id: role.id,
              discord_id: role.discord_id,
              color_hex: role.color_hex,
              name: role.name,
              will_be_deleted: !role.discord_id.in?(server_discord_role_ids)
            )
          end
        end
    end

    # Returns roles that have been returned by API call.
    def fetched_roles
      @fetched_roles ||=
        begin
          discord_roles_ids = discord_roles.pluck(:discord_id)

          discord_server_roles
            .each do |server_role|
              server_role.will_be_added = !server_role.id.in?(discord_roles_ids)
            end
            .reject do |role|
              role.name.eql?("@everyone") || role.position >= bot_position
            end
        end
    end

    private

    def discord_server_roles
      @discord_server_roles ||= request_server_roles
    rescue JSON::ParserError => e
      raise SyncError.new(t("invalid_response", { error: e }))
    rescue RestClient::BadRequest => e
      raise SyncError.new(t("bad_request", { error: e.response.body }))
    rescue ::StandardError => e
      raise SyncError.new(t("unknown_error", { error: e.message }))
    end

    def request_server_roles
      roles_request =
        Discordrb::API::Server.roles(
          "Bot #{school_config.bot_token}",
          school_config.server_id
        )

      unless roles_request&.code == 200
        raise SyncError.new(
                t("api_request_unsuccessful", { error: roles_request.code })
              )
      end

      JSON
        .parse(roles_request.body)
        .map do |role|
          OpenStruct.new(
            id: role["id"],
            name: role["name"],
            position: role["position"],
            color_hex: "##{(role["color"]).to_s(16)}",
            data: role
          )
        end
    end

    # Returns Bot's highest Role position in Discord role hierarchy.
    def bot_position
      @bot_position ||=
        begin
          member_request =
            Discordrb::API::Server.resolve_member(
              "Bot #{school_config.bot_token}",
              school_config.server_id,
              school_config.bot_user_id
            )

          unless member_request&.code == 200
            raise SyncError.new(
                    t(
                      "api_request_unsuccessful",
                      { error: member_request.code }
                    )
                  )
          end

          bot_role_ids = JSON.parse(member_request.body).dig("roles")

          discord_server_roles
            .filter_map { |sr| sr.position if bot_role_ids.include?(sr.id) }
            .max || 0
        end
    end

    def discord_roles
      @discord_roles ||= @school.discord_roles.order(created_at: :asc)
    end

    def school_config
      @school_config ||=
        begin
          config = Schools::Configuration::Discord.new(@school)

          unless config.configured?
            raise SyncError.new("Discord configuration is not configured.")
          end

          config
        end
    end

    def t(key, variables = {})
      I18n.t("services.discord.sync_roles_service.#{key}", **variables)
    end

    class SyncError < StandardError
    end
  end
end
