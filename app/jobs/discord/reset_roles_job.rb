module Discord
  class ResetRolesJob < ApplicationJob
    def perform(user_id)
      user = User.find(user_id)
      Discord::ResetRolesService.new(user).execute
    end
  end
end
