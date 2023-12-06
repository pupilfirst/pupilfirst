# TODO: Replace all usage of StudentSpecHelper with new SubmissionsHelper.
#
# IMPORTANT: Use SubmissionsHelper instead of this module.
#
# Some helpers to deal with students in specs.
module StudentSpecHelper
  # This 'completes' a target for a student - both team and student role targets.
  def complete_target(
    student,
    target,
    passed_at: Time.zone.now,
    grade: nil,
    latest: true
  )
    submit_target(
      student,
      target,
      passed: true,
      passed_at: passed_at,
      grade: grade,
      latest: latest
    )
  end

  def submit_target(
    student,
    target,
    passed: false,
    passed_at: Time.zone.now,
    grade: nil,
    latest: true
  )
    team = student.team
    assignment = target.assignments.not_archived.first
    if assignment.individual_assignment?
      (team&.students || [student]).each do |student|
        create_timeline_event(
          student,
          target,
          passed: passed,
          passed_at: passed_at,
          grade: grade,
          latest: latest
        )
      end
    else
      create_timeline_event(
        student,
        target,
        passed: passed,
        passed_at: passed_at,
        grade: grade,
        latest: latest
      )
    end
  end

  # This creates a timeline event for a target, attributed to supplied student.
  def create_timeline_event(
    student,
    target,
    passed: false,
    passed_at: nil,
    grade: nil,
    latest: true
  )
    options = timeline_event_options(student, passed, passed_at, target, latest)

    FactoryBot
      .create(:timeline_event, :with_owners, **options)
      .tap do |te|
        evaluation_criteria = target.assignments.first.evaluation_criteria
        # Add grades for passing submissions if evaluation criteria are present.
        if evaluation_criteria.present? && options[:passed_at].present?
          evaluation_criteria.each do |ec|
            create(
              :timeline_event_grade,
              timeline_event: te,
              grade: grade || rand(target.course.max_grade),
              evaluation_criterion: ec
            )
          end
        end
      end
  end

  private

  def timeline_event_options(student, passed, passed_at, target, latest)
    passed_at =
      if passed_at.present?
        passed_at
      else
        passed ? Time.zone.now : nil
      end

    { owners: [student], target: target, passed_at: passed_at, latest: latest }
  end
end
