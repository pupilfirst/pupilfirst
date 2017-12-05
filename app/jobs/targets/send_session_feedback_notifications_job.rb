module Targets
  # Send email to faculty, and slack message to #collective, asking for feedback about sessions that completed recently.
  class SendSessionFeedbackNotificationsJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform
      log 'Checking for sessions which were completed a while back to ask for feedback.'

      Target.sessions.where(session_at: (90.minutes.ago..60.minutes.ago)).each do |session|
        next if session.feedback_asked_at.present?

        # Send email to faculty asking for feedback.
        log "Sending feedback request to Faculty ##{session.faculty.name} for Session (Target) ##{session.id}"
        FacultyMailer.session_feedback(session).deliver_later

        # Send message to public Slack's #collective channel asking for feedback from founders.
        message_service = PublicSlack::MessageService.new
        log "Posting message requesting feedback from founders for Session (Target) ##{session.id} on #collective channel."
        message_service.post(message_for_colletive, channel: '#collective')

        # Update feedback asked at.
        session.feedback_asked_at = Time.zone.now
        session.save!

        log "All done. Session ##{session.id} now has feedback_asked_at = #{session.feedback_asked_at.iso8601}"
      end
    end

    private

    def message_for_colletive
      raise 'Not yet implemented'
    end
  end
end
