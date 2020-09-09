module Users
  class DeleteAccountJob < ApplicationJob
    queue_as :default

    def perform(user)
      Users::DeleteAccountService.new(user).execute
    end
  end
end
