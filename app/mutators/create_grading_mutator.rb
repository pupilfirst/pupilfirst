class CreateGradingMutator < ApplicationMutator
  include AuthorizeCoach

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
        # binding.pry
        TimelineEventGrade.create!(
          timeline_event: submission,
          evaluation_criterion: criterion,
          grade: grade_array[criterion.id.to_s]
        )
      end

      submission.update!(
        passed_at: (failed? ? nil : Time.now),
        evaluator: coach,
        evaluated_at: Time.now
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
    return unless valid_grading?

    errors[:base] << "Grading values supplied are invalid: #{grades.to_json}"
  end

  def submission
    @submission = current_school.timeline_events.where(id: submission_id).first
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

  def grade_array
    @grade_array ||= grades.each_with_object({}) do |key, value|
      value[key[:evaluation_criterion_id]] = key[:grade]
    end
  end

  def valid_grading?
    all_criteria_graded? && all_grades_valid?
  end

  def all_criteria_graded?
    evaluation_criteria.map(&:id).sort == grade_array.keys.sort
  end

  def all_grades_valid?
    grade_array.values.all? { |grade| grade.in?(1..max_grade) }
  end

  def max_grade
    @max_grade ||= submission.founder.startup.course.max_grade
  end

  def pass_grade
    @pass_grade ||= submission.founder.startup.course.pass_grade
  end

  def failed?
    grade_array.values.any? { |grade| grade < pass_grade }
  end
end
