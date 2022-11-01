module Discord
  class SyncProfileJob < ApplicationJob
    def perform(user_id)
      user = User.find(user_id)
      Discord::SyncProfileJob.new(user).execute
    end
  end
end
