module Targets
  # Send slack message to #collective asking for feedback about sessions that completed recently.
  class SendSessionFeedbackNotificationJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform
      log 'Checking for sessions which were completed a while back to ask for feedback.'

      Target.sessions.where(session_at: (90.minutes.ago..60.minutes.ago)).each do |session|
        next if session.feedback_asked_at.present?

        # Send message to public Slack's #collective channel asking for feedback from founders.
        message_service = PublicSlack::MessageService.new
        log "Posting message requesting feedback from founders for Session (Target) ##{session.id} on #collective channel."
        message_service.post(message: message_for_collective(session), channel: '#collective')

        # Update feedback asked at.
        session.feedback_asked_at = Time.zone.now
        session.save!

        log "All done. Session ##{session.id} now has feedback_asked_at = #{session.feedback_asked_at.iso8601}"
      end
    end

    private

    def message_for_collective(session)
      faculty_name = session.faculty.name

      I18n.t(
        "jobs.targets.send_session_feedback_notification.message",
        faculty_name: faculty_name,
        faculty_name_escaped: CGI.escape(faculty_name),
        session_title: CGI.escape(session.title),
        session_date: CGI.escape(session.session_at.strftime('%Y-%m-%d'))
      )
    end
  end
end
