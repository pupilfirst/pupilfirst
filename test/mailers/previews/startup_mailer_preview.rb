class StartupMailerPreview < ActionMailer::Preview
  def startup_rejected
    StartupMailer.startup_rejected(Startup.first)
  end
end
