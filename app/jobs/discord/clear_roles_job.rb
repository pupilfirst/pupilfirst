module Discord
  class ClearRolesJob < ApplicationJob
    def perform(discord_user_id, configuration)
      Discord::ClearRolesService.new(discord_user_id, configuration).execute
    end
  end
end
