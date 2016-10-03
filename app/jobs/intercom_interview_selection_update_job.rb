class IntercomInterviewSelectionUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(batch_application)
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: batch_application.team_lead.email, name: batch_application.team_lead.name)

    intercom.add_tag_to_user(user, 'Selected for Interview')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Selected for Interview</em>')
    intercom.update_user(user, application_stage: 'Selected for Interview')
  end
end
