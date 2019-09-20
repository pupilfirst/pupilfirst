class CreateGradingMutator < ApplicationMutator
  include AuthorizeFaculty

  attr_accessor :submission_id
  attr_accessor :grades
  attr_accessor :feedback

  validates :submission_id, presence: { message: 'Submission ID is required for grading' }

  validate :require_valid_submission
  validate :should_not_be_graded
  validate :valid_evaluation_criteria
  validate :valid_grading

  def grade
    TimelineEvent.transaction do
      evaluation_criteria.each do |criterion|
        TimelineEventGrade.create!(
          timeline_event: submission,
          evaluation_criterion: criterion,
          grade: grades[criterion.id]
        )
      end

      @timeline_event.update!(
        passed_at: (failed?(grades) ? nil : Time.now),
        evaluator: coach
      )
      send_feedback if feedback.present?
    end
  end

  private

  def send_feedback
    startup_feedback = StartupFeedback.create!(
      feedback: feedback,
      startup: submission.startup,
      faculty: coach,
      timeline_event: submission
    )
    StartupFeedbackModule::EmailService.new(startup_feedback, founder: submission.founder).send
  end

  def require_valid_submission
    return if submission.present?

    errors[:base] << "Unable to find Submission with id: #{submission_id}"
  end

  def should_not_be_graded
    return unless submission.reviewed?

    errors[:base] << "Submission cannot be Graded"
  end

  def valid_evaluation_criteria
    return if evaluation_criteria.present?

    errors[:base] << "Cannot grade Submission##{submission_id} without evaluation criteria"
  end

  def valid_grading
    return unless valid_grading?(grades)

    errors[:base] << "Grading values supplied are invalid: #{grades.to_json}"
  end

  def submission
    @submission = current_school.timeline_event.where(id: submission_id).first
  end

  def target
    @target ||= submission&.target
  end

  def course
    @course ||= target&.course
  end

  def coach
    @coach ||= current_user.faculty
  end

  def evaluation_criteria
    @evaluation_criteria ||= submission.evaluation_criteria.to_a
  end

  def valid_grading?(grades)
    return false unless grades.is_a? Hash

    all_criteria_graded?(grades) && all_grades_valid?(grades)
  end

  def all_criteria_graded?(grades)
    evaluation_criteria.map(&:id).sort == grades.keys.sort
  end

  def all_grades_valid?(grades)
    grades.values.all? { |grade| grade.in?(1..max_grade) }
  end

  def max_grade
    @max_grade ||= submission.founder.startup.course.max_grade
  end

  def pass_grade
    @pass_grade ||= submission.founder.startup.course.pass_grade
  end

  def failed?(grades)
    grades.values.any? { |grade| grade < pass_grade }
  end
end
