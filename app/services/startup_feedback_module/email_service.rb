module StartupFeedbackModule
  class EmailService
    include Loggable

    def initialize(startup_feedback, grading_details=nil)
      @startup_feedback = startup_feedback
      @grading_details = grading_details
    end

    def send
      log "Queuing feedback email to students with ids: #{@startup_feedback.timeline_event.founders.pluck(:id).join(', ')}"

      StartupMailer.feedback_as_email(@startup_feedback, @grading_details).deliver_later

      # Mark feedback as sent.
      @startup_feedback.update!(sent_at: Time.zone.now)
    end
  end
end
