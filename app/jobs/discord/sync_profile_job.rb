module Discord
  class SyncProfileJob < ApplicationJob
    def perform(user)
      Discord::SyncProfileService.new(user).execute
    end
  end
end
