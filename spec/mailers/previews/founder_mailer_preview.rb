# require 'mailer_preview_helper'

class FounderMailerPreview < ActionMailer::Preview
  def connect_request_feedback
    FounderMailer.connect_request_feedback(connect_request)
  end

  private

  def connect_request
    ConnectRequest.new(
      id: 1,
      connect_slot: connect_slot,
      startup: Startup.last,
      questions: Faker::Lorem.paragraphs(number: 2).join("\n\n"),
      status: ConnectRequest::STATUS_CONFIRMED,
      meeting_link: 'https://example.com/meeting_url'
    )
  end

  def connect_slot
    ConnectSlot.new(
      faculty: Faculty.first,
      slot_at: 2.days.from_now
    )
  end
end
