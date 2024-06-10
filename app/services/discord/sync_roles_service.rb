module Discord
  class SyncRolesService
    attr_reader :error_message
    def initialize(school:)
      @school = school
      @error_message = ""
    end

    def sync
      unless school_config.configured?
        @error_message = "School Discord server is not configured."
        return false
      end

      rest_client =
        Discordrb::API::Server.roles(
          "Bot #{school_config.bot_token}",
          school_config.server_id
        )

      bot_rc =
        Discordrb::API::Server.resolve_member(
          "Bot #{school_config.bot_token}",
          school_config.server_id,
          school_config.bot_user_id
        )

      unless rest_client.code == 200 && bot_rc.code == 200
        @error_message =
          "API request to Discord was not successful, response code: #{rest_client.code}"

        return false
      end

      server_roles =
        JSON
          .parse(rest_client.body)
          .map do |role|
            OpenStruct.new(
              id: role["id"],
              name: role["name"],
              position: role["position"],
              color_rgb: role["color"],
              data: role
            )
          end

      bot_role_ids = JSON.parse(bot_rc.body).dig("roles")

      sync_server_roles(server_roles, bot_role_ids)
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid response from Discord #{e.message}"
      @error_message = "Got invalid response from Discord."

      false
    rescue RestClient::BadRequest => e
      Rails.logger.error "Bad request made while fetching discord roles #{e.response.body}"
      @error_message = "Bad request made while fetching discord roles."

      false
    rescue Discordrb::Errors::UnknownError => e
      @error_message = "Please recheck you configuration values. #{e.message}"
      Rails.logger.error @error_message

      false
    end

    private

    attr_reader :school

    def sync_server_roles(server_roles, bot_role_ids)
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

        if sr.position >= bot_position(bot_role_ids, server_roles) &&
             role.new_record?
          next
        end

        role.name = sr.name
        role.position = sr.position
        role.color_hex = hex_of(sr.color_rgb)
        role.data = sr.data

        role.save!
      end
    end

    def bot_position(role_ids, server_roles)
      @bot_position ||=
        begin
          position = 0

          server_roles.each do |sr|
            if role_ids.include?(sr.id) && sr.position > position
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
