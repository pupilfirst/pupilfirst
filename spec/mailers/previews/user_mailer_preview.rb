# require 'mailer_preview_helper'

class UserMailerPreview < ActionMailer::Preview
  def reminder_to_complete_founder_profile
    UserMailer.reminder_to_complete_founder_profile(User.first)
  end

  def cofounder_request
    UserMailer.cofounder_request(User.first.email, User.second)
  end

  def incubation_request_submitted
    UserMailer.incubation_request_submitted(User.first)
  end

  def request_to_be_a_founder
    UserMailer.request_to_be_a_founder(User.first, Startup.first, User.second)   
  end

  def password_changed
    UserMailer.password_changed(User.first)
  end
end
