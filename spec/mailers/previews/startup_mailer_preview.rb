class StartupMailerPreview < ActionMailer::Preview
  def startup_rejected
    StartupMailer.startup_rejected(Startup.first)
  end

  def startup_approved
    StartupMailer.startup_approved(Startup.first)
  end

  def reminder_to_complete_startup_profile
    StartupMailer.reminder_to_complete_startup_profile(Startup.first)
  end

  def reminder_to_complete_startup_info
    StartupMailer.reminder_to_complete_startup_info(Startup.first)
  end

  def agreement_expiring_soon
    startup = Startup.first
    expires_in = 30
    renew_within = 15
    StartupMailer.agreement_expiring_soon(startup, expires_in, renew_within)
  end

  def feedback_as_email
    startup_feedback = StartupFeedback.first
    StartupMailer.feedback_as_email(startup_feedback)
  end
end
