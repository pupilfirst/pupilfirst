module Discord
  class SyncNameJob < ApplicationJob
    def perform(user_id)
      user = User.find(user_id)
      Discord::SyncNameService.new(user).execute
    end
  end
end
