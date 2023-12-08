module SubmissionsHelper
  SUBMISSION_PASS = :pass
  SUBMISSION_FAIL = :fail
  SUBMISSION_NONE = :none

  def complete_target(target, student, evaluator: nil, latest: true)
    submit_target(
      target,
      student,
      submission_evaluation: SUBMISSION_PASS,
      evaluator: evaluator,
      latest: latest
    )
  end

  def fail_target(target, student, evaluator: nil, latest: true)
    submit_target(
      target,
      student,
      submission_evaluation: SUBMISSION_FAIL,
      evaluator: evaluator,
      latest: latest
    )
  end

  def submit_target(
    target,
    student,
    submission_evaluation: SUBMISSION_NONE,
    evaluator: nil,
    latest: true
  )
    assignment = target.assignments.first
    options =
      submission_options(
        target,
        assignment,
        student,
        submission_evaluation,
        evaluator,
        latest
      )

    FactoryBot
      .create(:timeline_event, :with_owners, **options)
      .tap do |submission|
        grade_submission(submission, submission_evaluation, assignment)
      end
  end

  def grade_submission(submission, submission_evaluation, assignment)
    if assignment.evaluation_criteria.present? &&
         submission_evaluation == SUBMISSION_PASS
      assignment.evaluation_criteria.each do |ec|
        evaluation_grade = rand(ec.max_grade)
        create(
          :timeline_event_grade,
          timeline_event: submission,
          grade: evaluation_grade,
          evaluation_criterion: ec
        )
      end
    end
  end

  private

  # This is a hack to avoid having to pass an evaluator ID.
  def get_evaluator(students)
    school = students.first.school

    school.faculty.first ||
      begin
        user = FactoryBot.create(:user, school: school)
        FactoryBot.create(:faculty, user: user)
      end
  end

  def submission_options(
    target,
    assignment,
    student,
    submission_evaluation,
    evaluator,
    latest
  )
    students =
      (
        if (target.team_target? && student.team)
          student.team.students
        else
          [student]
        end
      )

    passed_at, evaluated_at =
      if assignment.evaluation_criteria.present?
        case submission_evaluation
        when SUBMISSION_PASS
          [Time.zone.now, Time.zone.now]
        when SUBMISSION_FAIL
          [nil, Time.zone.now]
        else
          [nil, nil]
        end
      else
        [Time.zone.now, nil]
      end

    {
      owners: students,
      target: target,
      latest: latest,
      passed_at: passed_at,
      evaluated_at: evaluated_at,
      evaluator:
        evaluated_at.present? ? (evaluator || get_evaluator(students)) : nil
    }
  end
end
