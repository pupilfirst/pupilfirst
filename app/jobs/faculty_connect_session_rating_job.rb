class FacultyConnectSessionRatingJob < ApplicationJob
  queue_as :default

  def perform(connect_request_id)
    @connect_request_id = connect_request_id

    return unless job_is_relevant?

    # Check if the timing is still correct. If meeting had been rescheduled to the future, create a new job, otherwise
    # run immediately.
    if !Rails.env.production? || connect_request.time_for_feedback_mail?
      send_mails(connect_request)
    else
      connect_slot = connect_request.connect_slot
      FacultyConnectSessionRatingJob.set(wait_until: connect_slot.slot_at + 45.minutes).perform_later(@connect_request_id)
    end
  end

  def send_mails(connect_request)
    FacultyMailer.connect_request_feedback(connect_request).deliver_later
    FounderMailer.connect_request_feedback(connect_request).deliver_later

    # Set feedback mails to sent.
    connect_request.feedback_mails_sent!
  end

  private

  def connect_request
    @connect_request ||= ConnectRequest.find_by id: @connect_request_id
  end

  # Run the job only if associated startup and faculty are still present. Also, don't run the job if feedback mails
  # have already been sent, or if the connect request isn't in confirmed state.
  def job_is_relevant?
    (connect_request.present? && connect_request.startup.present? && connect_request.faculty.present?) && connect_request.confirmed? && !connect_request.feedback_mails_sent?
  end
end
