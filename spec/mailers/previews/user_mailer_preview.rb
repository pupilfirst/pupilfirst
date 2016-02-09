# require 'mailer_preview_helper'

class UserMailerPreview < ActionMailer::Preview
  def cofounder_request
    UserMailer.cofounder_request(User.first.email, User.second)
  end

  def incubation_request_submitted
    UserMailer.incubation_request_submitted(User.first)
  end

  def password_changed
    UserMailer.password_changed(User.first)
  end

  def connect_request_feedback
    UserMailer.connect_request_feedback(ConnectRequest.first)
  end
end
