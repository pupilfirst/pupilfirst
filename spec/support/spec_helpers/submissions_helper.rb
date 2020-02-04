module SubmissionsHelper
  GRADE_PASS = :pass
  GRADE_FAIL = :fail
  GRADE_NONE = :none

  def complete_target(target, student)
    submit_target(target, student, grade: GRADE_PASS)
  end

  def fail_target(target, student)
    submit_target(target, student, grade: GRADE_FAIL)
  end

  # rubocop:disable Metrics/MethodLength
  def submit_target(target, student, grade: GRADE_NONE)
    options = submission_options(target, student, grade)

    FactoryBot.create(:timeline_event, options).tap do |submission|
      if target.evaluation_criteria.present? && grade != GRADE_NONE
        target.evaluation_criteria.each do |ec|
          computed_grade = case grade
            when GRADE_PASS
              rand(ec.pass_grade..ec.max_grade)
            else
              (ec.pass_grade - 1).tap do |failing_grade|
                raise "Spec asked for failed status on a target with non-failing criteria" if failing_grade.zero?
              end
          end

          create(
            :timeline_event_grade,
            timeline_event: submission,
            grade: computed_grade,
            evaluation_criterion: ec
          )
        end
      end
    end
  end

  # rubocop:enable Metrics/MethodLength

  private

  # This is a hack to avoid having to pass an evaluator ID.
  def evaluator(students)
    school = students.first.school

    school.faculty.first || begin
      user = FactoryBot.create(:user, school: school)
      FactoryBot.create(:faculty, user: user)
    end
  end

  def submission_options(target, student, grade) # rubocop:disable Metrics/MethodLength
    students = if target.team_target?
      student.startup.founders
    else
      [student]
    end

    (passed_at, evaluated_at) = if target.evaluation_criteria.present?
      case grade
        when GRADE_PASS
          [Time.zone.now, Time.zone.now]
        when GRADE_FAIL
          [nil, Time.zone.now]
        else
          [nil, nil]
      end
    else
      [Time.zone.now, nil]
    end

    {
      founders: students,
      target: target,
      latest: true,
      passed_at: passed_at,
      evaluated_at: evaluated_at,
      evaluator: evaluated_at.present? ? evaluator(students) : nil
    }
  end
end
