module Intercom
  class UnsubscribeJob < ApplicationJob
    queue_as :default

    def perform(email)
      intercom = IntercomClient.new
      user = intercom.find_or_create_user(email: email)
      user.unsubscribed_from_emails = true
      intercom.save_user(user)
    end
  end
end
