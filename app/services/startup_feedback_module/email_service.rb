module StartupFeedbackModule
  class EmailService
    include Loggable

    def initialize(startup_feedback, founder: nil)
      @startup_feedback = startup_feedback
      @founder = founder
    end

    def send
      log "Queuing feedback email to #{@founder.present? ? @founder.email : "all founders in Startup##{@startup_feedback.startup.id}"}."

      StartupMailer.feedback_as_email(@startup_feedback, founder: @founder).deliver_later

      # Mark feedback as sent.
      @startup_feedback.update!(sent_at: Time.now)
    end
  end
end
