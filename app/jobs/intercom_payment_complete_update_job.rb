class IntercomPaymentCompleteUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(batch_applicant)
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: batch_applicant.email, name: batch_applicant.name)

    intercom.add_tag_to_user(user, 'Paid Applicant')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Paid Applicant</em>')
    IntercomUpdateUserJob.perform_later(user.email, application_stage: 'Payment Completed')
  end
end
