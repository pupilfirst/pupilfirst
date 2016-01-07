class FacultyConnectSessionRatingJob < ActiveJob::Base
  queue_as :default

  def perform(connect_request)
    # Run the job only if associated startup and faculty are still present.
    return unless connect_request.startup.present? && connect_request.faculty.present?

    # Don't run the job if feedback mails have already been sent, or if the connect request isn't in confirmed state.
    return if connect_request.feedback_mails_sent? || connect_request.unconfirmed?

    # Check if the timing is still correct. If meeting had been rescheduled to the future, create a new job, otherwise run immediately.
    if connect_request.time_for_feedback_mail?
      FacultyMailer.connect_request_feedback(connect_request).deliver_later
      UserMailer.connect_request_feedback(connect_request).deliver_later
    else
      connect_request.create_faculty_connect_session_rating_job
    end

    # Set feedback mails to sent.
    connect_request.feedback_mails_sent!
  end
end
