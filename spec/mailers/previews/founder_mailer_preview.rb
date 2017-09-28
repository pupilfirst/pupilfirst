# require 'mailer_preview_helper'

class FounderMailerPreview < ActionMailer::Preview
  def connect_request_feedback
    FounderMailer.connect_request_feedback(ConnectRequest.first)
  end

  def invite
    founder = Founder.first
    founder.invitation_token = 'TEST_TOKEN_VALUE'
    FounderMailer.invite(founder, Startup.first)
  end

  def slack_removal
    founder = Founder.first
    FounderMailer.slack_removal(founder)
  end
end
