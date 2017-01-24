class IntercomLastApplicantEventUpdateJob < ApplicationJob
  queue_as :default

  def perform(batch_applicant, event)
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: batch_applicant.email, name: batch_applicant.name)

    intercom.add_tag_to_user(user, tags[event.to_sym])
    intercom.add_note_to_user(user, "Auto-tagged as <em>#{notes[event.to_sym]}</em>")
    intercom.update_user(user, last_applicant_event: event_description[event.to_sym])
  end

  def tags
    {
      submitted_application: 'Applicant',
      payment_initiated: 'Payment Initiated',
      payment_complete: 'Paid Applicant',
      payment_skipped: 'Payment Skipped',
      coding_task_submitted: 'Coding Task Submitted',
      video_task_submitted: 'Video Task Submitted',
      selected_for_interview: 'Selected For Interview',
      agreements_sent: 'Agreements Sent'
    }
  end

  def notes
    {
      submitted_application: 'Applicant',
      payment_initiated: 'Payment Initiated',
      payment_complete: 'Paid Applicant',
      payment_skipped: 'Payment Skipped',
      coding_task_submitted: 'Coding Task Submitted',
      video_task_submitted: 'Video Task Submitted',
      selected_for_interview: 'Selected For Interview',
      agreements_sent: 'Agreements Sent'
    }
  end

  def event_description
    {
      submitted_application: 'Submitted Application',
      payment_initiated: 'Payment Initiated',
      payment_complete: 'Payment Completed',
      payment_skipped: 'Payment Skipped',
      coding_task_submitted: 'Coding Task Submitted',
      video_task_submitted: 'Video Task Submitted',
      selected_for_interview: 'Selected For Interview',
      agreements_sent: 'Agreements Sent'
    }
  end
end
