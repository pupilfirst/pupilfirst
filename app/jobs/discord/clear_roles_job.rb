module Discord
  class ClearRolesJob < ApplicationJob
    def perform(discord_user_id, school)
      Discord::ClearRolesService.new(
        discord_user_id,
        Schools::Configuration::Discord.new(school)
      ).execute
    end
  end
end
