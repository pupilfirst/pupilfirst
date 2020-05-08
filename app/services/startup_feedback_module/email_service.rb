module StartupFeedbackModule
  class EmailService
    include Loggable

    def initialize(startup_feedback)
      @startup_feedback = startup_feedback
    end

    def send
      log "Queuing feedback email to students with ids: #{@startup_feedback.timeline_event.founders.pluck(:id).join(', ')}"

      StartupMailer.feedback_as_email(@startup_feedback).deliver_later

      # Mark feedback as sent.
      @startup_feedback.update!(sent_at: Time.zone.now)
    end
  end
end
