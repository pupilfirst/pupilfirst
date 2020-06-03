module Users
  class DeleteAccountJob < ApplicationJob
    queue_as :default

    def perform(user)
      return if user.blank?

      Users::DeleteAccountService.new(user).execute
    end
  end
end
