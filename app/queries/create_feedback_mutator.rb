class CreateFeedbackMutator < ApplicationQuery
  include AuthorizeCoach

  property :submission_id, validates: { presence: true }
  property :feedback, validates: { presence: true, length: { maximum: 10_000 } }

  validate :require_valid_submission

  def create_feedback
    StartupFeedback.transaction do
      startup_feedback = StartupFeedback.create!(
        feedback: feedback,
        startup: submission.startup,
        faculty: coach,
        timeline_event: submission,
      )
      StartupFeedbackModule::EmailService.new(startup_feedback).send
    end
  end

  private

  def require_valid_submission
    return if submission.present?

    errors[:base] << "Unable to find Submission with id: #{submission_id}"
  end

  def submission
    @submission = TimelineEvent.find_by(id: submission_id)
  end

  def course
    @course ||= submission&.course
  end

  def coach
    @coach ||= current_user.faculty
  end
end
