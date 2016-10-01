class IntercomUpdateUserJob < ActiveJob::Base
  queue_as :default

  def perform(email, attributes)
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: email)
    intercom.update_user(user, attributes)
  end
end
