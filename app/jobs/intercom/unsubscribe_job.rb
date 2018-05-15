module Intercom
  class UnsubscribeJob < ApplicationJob
    queue_as :default

    def perform(email)
      return true
      # rubocop:disable Lint/UnreachableCode
      intercom = IntercomClient.new
      user = intercom.find_or_create_user(email: email)
      user.unsubscribed_from_emails = true
      intercom.save_user(user)
      # rubocop:enable Lint/UnreachableCode
    end
  end
end
