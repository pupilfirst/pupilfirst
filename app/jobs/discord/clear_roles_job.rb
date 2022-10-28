module Discord
  class ClearRolesJob < ApplicationJob
    def perform(user_id, discord_user_id)
      user = User.find(user_id)
      Discord::ClearRolesService.new(user, discord_user_id).execute
    end
  end
end
