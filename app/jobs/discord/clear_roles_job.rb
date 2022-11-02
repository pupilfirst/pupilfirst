module Discord
  class ClearRolesJob < ApplicationJob
    def perform(discord_user_id)
      Discord::ClearRolesService.new(discord_user_id).execute
    end
  end
end
