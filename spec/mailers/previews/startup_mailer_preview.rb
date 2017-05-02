class StartupMailerPreview < ActionMailer::Preview
  def feedback_as_email
    startup_feedback = StartupFeedback.first
    StartupMailer.feedback_as_email(startup_feedback)
  end

  def connect_request_confirmed
    connect_request = ConnectRequest.first

    StartupMailer.connect_request_confirmed(connect_request)
  end
end
