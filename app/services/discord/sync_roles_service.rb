module Discord
  class SyncRolesService
    attr_reader :error_message

    def initialize(school:)
      @school = school
      @error_message = ""
    end

    def sync
      return false unless sync_ready?

      sync_server_roles
      true
    end

    def cached_roles
      return [] unless sync_ready?

      @cached_roles ||=
        begin
          server_discord_role_ids = @server_roles.pluck(:id)
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

    def fetched_roles
      return [] unless sync_ready?

      @fetched_roles ||=
        begin
          discord_roles_ids = discord_roles.pluck(:discord_id)

          @server_roles.each do |server_role|
            server_role.will_be_added = !server_role.id.in?(discord_roles_ids)
          end
        end
    end

    def deleted_roles?
      return false unless sync_ready?

      @deleted_roles ||=
        discord_roles.where.not(discord_id: server_roles.pluck(:id)).exists?
    end

    def sync_ready?
      unless school_config.configured?
        return error("School Discord server is not configured.")
      end

      unless fetch_roles
        return error("API request to discord was not successful.")
      end

      true
    end

    private

    attr_reader :school, :server_roles, :bot_role_ids

    def fetch_roles
      return true if @server_roles.present?

      roles_request =
        Discordrb::API::Server.roles(
          "Bot #{school_config.bot_token}",
          school_config.server_id
        )

      member_request =
        Discordrb::API::Server.resolve_member(
          "Bot #{school_config.bot_token}",
          school_config.server_id,
          school_config.bot_user_id
        )

      unless roles_request.code == 200 && member_request.code == 200
        return(
          error "API request to Discord was not successful, response code: #{roles_request.code}"
        )
      end

      parse_requests(roles_request, member_request)

      true
    rescue JSON::ParserError => e
      error("Got invalid response from Discord. Response: #{e}")
    rescue RestClient::BadRequest => e
      error("Bad request made while fetching discord roles. #{e.response.body}")
    rescue Discordrb::Errors::UnknownError => e
      error("Please recheck you configuration values. #{e.message}")
    rescue ::StandardError => e
      error("Please recheck your configuration values. #{e.message}")
    end

    def parse_requests(roles_request, member_request)
      @bot_role_ids = JSON.parse(member_request.body).dig("roles")

      @server_roles =
        JSON
          .parse(roles_request.body)
          .map do |role|
            OpenStruct.new(
              id: role["id"],
              name: role["name"],
              position: role["position"],
              color_hex: hex_of(role["color"]),
              data: role
            )
          end

      @server_roles =
        @server_roles.filter do |role|
          !role.name.eql?("@everyone") && role.position < bot_position
        end
    end

    def sync_server_roles
      deleted_discord_roles =
        discord_roles.where.not(discord_id: server_roles.pluck(:id))

      server_roles.each do |sr|
        next if sr.name.eql?("@everyone")

        role =
          DiscordRole.find_or_initialize_by(
            school_id: school.id,
            discord_id: sr.id
          )

        next if sr.position >= bot_position && role.new_record?

        role.update!(
          name: sr.name,
          position: sr.position,
          color_hex: sr.color_hex,
          data: sr.data
        )
      end

      # Remove any deleted role from school.config.default_role_ids.
      updated_default_roles =
        (school.configuration.dig("discord", "default_role_ids") || []) -
          deleted_discord_roles.pluck(:discord_id)

      updated_config =
        school.configuration.deep_merge(
          { "discord" => { default_role_ids: updated_default_roles } }
        )

      if updated_default_roles.present?
        school.update!(configuration: updated_config)
      end

      deleted_discord_roles.each(&:destroy)
    end

    def bot_position
      @bot_position ||=
        server_roles
          .map { |sr| sr.position if bot_role_ids.include?(sr.id) }
          .compact
          .max || 0
    end

    def hex_of(rgb)
      red = (rgb / 65_536).to_i
      green = ((rgb % 65_536) / 256).to_i
      blue = (rgb % 256).to_i

      sprintf("#%02X%02X%02X", red, green, blue)
    end

    def discord_roles
      @discord_roles ||= school.discord_roles
    end

    def school_config
      @school_config ||= Schools::Configuration::Discord.new(school)
    end

    def error(message)
      @error_message = message
      false
    end
  end
end
