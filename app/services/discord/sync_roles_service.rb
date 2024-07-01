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
