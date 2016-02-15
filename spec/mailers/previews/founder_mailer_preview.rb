# require 'mailer_preview_helper'

class FounderMailerPreview < ActionMailer::Preview
  def cofounder_request
    FounderMailer.cofounder_request(Founder.first.email, Founder.second)
  end

  def incubation_request_submitted
    FounderMailer.incubation_request_submitted(Founder.first)
  end

  def password_changed
    FounderMailer.password_changed(Founder.first)
  end

  def connect_request_feedback
    FounderMailer.connect_request_feedback(ConnectRequest.first)
  end
end
