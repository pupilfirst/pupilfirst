module Discord
  class SyncNameJob < ApplicationJob
    def perform(user)
      Discord::SyncNameService.new(user).execute
    end
  end
end
