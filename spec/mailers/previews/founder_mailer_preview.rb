# require 'mailer_preview_helper'

class FounderMailerPreview < ActionMailer::Preview
  def cofounder_request
    FounderMailer.cofounder_request(Founder.first.email, Founder.second)
  end

  def incubation_request_submitted
    FounderMailer.incubation_request_submitted(Founder.first)
  end

  def connect_request_feedback
    FounderMailer.connect_request_feedback(ConnectRequest.first)
  end

  def invite
    founder = Founder.first
    founder.invitation_token = 'TEST_TOKEN_VALUE'
    FounderMailer.invite(founder, Startup.first)
  end
end
