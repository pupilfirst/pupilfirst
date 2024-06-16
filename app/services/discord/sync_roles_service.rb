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
      return nil unless sync_ready?

      discord_roles
    end

    def fetched_roles
      return nil unless sync_ready?

      @server_roles
    end

    def deleted_roles
      return nil unless sync_ready?

      @deleted_roles ||=
        discord_roles.where.not(discord_id: server_roles.pluck(:id))
    end

    def sync_ready?
      unless school_config.configured?
        @error_message = "School Discord server is not configured."
        return false
      end

      return false unless fetch_roles

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
        @error_message =
          "API request to Discord was not successful, response code: #{roles_request.code}"

        return false
      end

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

      @bot_role_ids = JSON.parse(member_request.body).dig("roles")

      true
    rescue JSON::ParserError => e
      @error_message = "Got invalid response from Discord. Response: #{e}"

      false
    rescue RestClient::BadRequest => e
      @error_message =
        "Bad request made while fetching discord roles. #{e.response.body}"

      false
    rescue Discordrb::Errors::UnknownError => e
      @error_message = "Please recheck you configuration values. #{e.message}"

      false
    rescue ::StandardError => e
      @error_message = "Please recheck your configuration values. #{e.message}"

      false
    end

    def sync_server_roles
      deleted_discord_roles =
        discord_roles.where.not(discord_id: server_roles.pluck(:id))

      deleted_discord_roles.each(&:destroy)

      server_roles.each do |sr|
        next if sr.name.eql?("@everyone")

        role =
          DiscordRole.find_or_initialize_by(
            school_id: school.id,
            discord_id: sr.id
          )

        next if sr.position >= bot_position && role.new_record?

        role.name = sr.name
        role.position = sr.position
        role.color_hex = sr.color_hex
        role.data = sr.data

        role.save!
      end
    end

    def bot_position
      @bot_position ||=
        begin
          position = 0

          server_roles.each do |sr|
            if bot_role_ids.include?(sr.id) && sr.position > position
              position = sr.position
            end
          end

          position
        end
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
  end
end
