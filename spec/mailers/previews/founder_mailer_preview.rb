# require 'mailer_preview_helper'

class FounderMailerPreview < ActionMailer::Preview
  def connect_request_feedback
    FounderMailer.connect_request_feedback(ConnectRequest.first)
  end
end
