class IntercomPaymentInitiatedUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(batch_application)
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: batch_application.team_lead.email, name: batch_application.team_lead.name)

    intercom.add_tag_to_user(user, 'Payment Initiated')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Payment Initiated</em>')
    IntercomUpdateUserJob.perform_later(user.email, application_stage: 'Payment Initiated')
  end
end
