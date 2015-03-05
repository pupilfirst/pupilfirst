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

  def partnership_application
    StartupMailer.partnership_application(Startup.first, User.first)    
  end

  def notify_svrep_about_startup_update
    StartupMailer.notify_svrep_about_startup_update(Startup.first)    
  end

  def apply_now
    StartupMailer.apply_now(Startup.first)    
  end

  def agreement_expiring_soon
    startup = Startup.first
    expires_in = ((startup.agreement_ends_at - Time.zone.now) / 1.day).round
    renew_within = expires_in - 15
    StartupMailer.agreement_expiring_soon(startup, expires_in, renew_within)    
  end
  
end
