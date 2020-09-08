class CreateGradingMutator < ApplicationQuery
  include AuthorizeCoach

  property :submission_id, validates: { presence: { message: 'Submission ID is required for grading' } }
  property :feedback, validates: { length: { maximum: 10_000 } }
  property :note, validates: { length: { maximum: 10_000 } }
  property :grades
  property :checklist

  validate :require_valid_submission
  validate :should_not_be_graded
  validate :valid_evaluation_criteria
  validate :valid_grading
  validate :right_shape_for_checklist
  validate :checklist_data_is_not_mutated

  def grade
    TimelineEvent.transaction do
      evaluation_criteria.each do |criterion|
        TimelineEventGrade.create!(
          timeline_event: submission,
          evaluation_criterion: criterion,
          grade: grade_hash[criterion.id.to_s],
        )
      end

      submission.update!(
        passed_at: (failed? ? nil : Time.zone.now),
        evaluator: coach,
        evaluated_at: Time.zone.now,
        checklist: checklist,
      )

      TimelineEvents::AfterGradingJob.perform_later(submission)
      update_coach_note if note.present?
      send_feedback if feedback.present?
    end
  end

  private

  def update_coach_note
    submission.founders.each do |student|
      CoachNote.create!(note: note, author_id: current_user.id, student_id: student.id)
    end
  end

  def right_shape_for_checklist
    return if checklist.respond_to?(:all?) && checklist.all? do |item|
      item['title'].is_a?(String) && item['kind'].in?(Target.valid_checklist_kind_types) && item['status'].in?([TimelineEvent::CHECKLIST_STATUS_FAILED, TimelineEvent::CHECKLIST_STATUS_NO_ANSWER]) && item['result'].is_a?(String)
    end

    errors[:base] << 'Invalid checklist'
  end

  def checklist_data_is_not_mutated
    old_checklist = submission.checklist.map do |c|
      [c['title'], c['kind'], c['result']]
    end

    new_checklist = checklist.map do |c|
      [c['title'], c['kind'], c['result']]
    end

    return if (old_checklist - new_checklist).empty? && old_checklist.count == new_checklist.count

    errors[:base] << 'Invalid checklist'
  end

  def send_feedback
    startup_feedback = StartupFeedback.create!(
      feedback: feedback,
      startup: submission.startup,
      faculty: coach,
      timeline_event: submission,
    )

    StartupFeedbackModule::EmailService.new(startup_feedback).send
  end

  def require_valid_submission
    return if submission.present?

    errors[:base] << "Unable to find Submission with id: #{submission_id}"
  end

  def should_not_be_graded
    return unless submission.reviewed?

    errors[:base] << 'Submission cannot be Graded'
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
    @submission = TimelineEvent.find_by(id: submission_id)
  end

  def course
    @course ||= submission&.course
  end

  def coach
    @coach ||= current_user.faculty
  end

  def evaluation_criteria
    @evaluation_criteria ||= submission.evaluation_criteria
  end

  def grade_hash
    @grade_hash ||= grades.each_with_object({}) do |incoming_grade, grade_hash|
      criteria_id = incoming_grade[:evaluation_criterion_id]
      grade = incoming_grade[:grade]
      grade_hash[criteria_id] = grade
    end
  end

  def valid_grading?
    all_criteria_graded? && all_grades_valid?
  end

  def all_criteria_graded?
    (evaluation_criteria.pluck(:id) - grade_hash.keys).empty?
  end

  def all_grades_valid?
    grade_hash.all? { |ec_id, grade| grade.in?(1..max_grades[ec_id]) }
  end

  def max_grades
    @max_grades ||= grade_hash.keys.index_with do |ec_id|
      evaluation_criteria.find(ec_id).max_grade
    end
  end

  def pass_grades
    @pass_grades ||= grade_hash.keys.index_with do |ec_id|
      evaluation_criteria.find(ec_id).pass_grade
    end
  end

  def failed?
    grade_hash.any? { |ec_id, grade| grade < pass_grades[ec_id] }
  end

  def allow_token_auth?
    true
  end
end
