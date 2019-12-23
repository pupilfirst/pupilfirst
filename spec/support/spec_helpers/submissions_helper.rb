module SubmissionsHelper
  GRADE_PASS = :pass
  GRADE_FAIL = :fail
  GRADE_NONE = :none

  def complete_target(target, student)
    submit_target(target, student, grade: GRADE_PASS)
  end

  def submit_target(target, student, grade: GRADE_NONE)
    options = submission_options(target, student, grade)

    submission = FactoryBot.create(:timeline_event, options)

    if target.evaluation_criteria.present? && grade != GRADE_NONE
      target.evaluation_criteria.each do |ec|
        computed_grade = case grade
          when GRADE_PASS
            rand(ec.pass_grade..ec.max_grade)
          else
            ec.pass_grade - 1
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

  private

  def submission_options(target, student, grade)
    students = student.respond_to?(:to_a) ? student.to_a : [student]

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
      evaluated_at: evaluated_at
    }
  end
end
