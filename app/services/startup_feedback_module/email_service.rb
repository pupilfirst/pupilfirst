module StartupFeedbackModule
  class EmailService
    include Loggable

    def initialize(startup_feedback, include_grades: false)
      @startup_feedback = startup_feedback
      @include_grades = include_grades
    end

    def send
      log "Queuing feedback email to students with ids: #{@startup_feedback.timeline_event.students.pluck(:id).join(', ')}"

      StartupMailer.feedback_as_email(@startup_feedback, @include_grades).deliver_later

      # Mark feedback as sent.
      @startup_feedback.update!(sent_at: Time.zone.now)
    end
  end
end
