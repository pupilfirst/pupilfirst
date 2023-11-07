class SubmissionsResolver < ApplicationQuery
  property :course_id
  property :status
  property :sort_direction
  property :sort_criterion
  property :personal_coach_id
  property :assigned_coach_id
  property :reviewing_coach_id
  property :target_id
  property :search
  property :include_inactive

  def submissions
    applicable_submissions.distinct.order(
      "#{sort_criterion_string} #{sort_direction_string}"
    )
  end

  def authorized?
    return false if course&.school != current_school

    return true if current_school_admin.present?

    return false if coach.blank?

    coach.courses.exists?(id: course)
  end

  def coach
    @coach ||= current_user.faculty
  end

  def sort_direction_string
    case sort_direction
    when "Ascending"
      "ASC"
    when "Descending"
      "DESC"
    else
      raise "#{sort_direction} is not a valid sort direction"
    end
  end

  def sort_criterion_string
    case sort_criterion
    when "SubmittedAt"
      "created_at"
    when "EvaluatedAt"
      "evaluated_at"
    else
      raise "#{sort_criterion} is not a valid sort criterion"
    end
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def applicable_submissions
    stage_1 = course.timeline_events.not_auto_verified.live

    # Filter by target
    stage_2 =
      if course.targets.exists?(id: target_id)
        stage_1.where(target_id: target_id)
      else
        stage_1
      end

    stage_3 = filter_by_status(stage_2)

    # Filter by personal coach
    stage_4 =
      if course.faculty.exists?(id: personal_coach_id)
        stage_3.joins(students: :faculty_student_enrollments).where(
          faculty_student_enrollments: {
            faculty_id: personal_coach_id
          }
        )
      else
        stage_3
      end

    # Filter by assigned coach
    stage_5 =
      if course.faculty.exists?(id: assigned_coach_id)
        stage_4.where(reviewer: assigned_coach_id)
      else
        stage_4
      end

    # Filter by evaluator coach
    if course.faculty.exists?(id: reviewing_coach_id)
      stage_5.where(evaluator_id: reviewing_coach_id)
    else
      stage_5
    end.from_students(students)
  end

  def filter_by_status(submissions)
    return submissions if status.blank?

    case status
    when "Pending"
      submissions.pending_review
    when "Reviewed"
      submissions.evaluated_by_faculty
    else
      raise "Unexpected status '#{status}' encountered when resolving submissions"
    end
  end

  def students
    @students ||=
      begin
        scope =
          if current_school_admin.present?
            course.students
          else
            course.students.where(cohort_id: coach.cohorts)
          end

        scope = include_inactive ? scope : scope.active

        if search.present?
          students_with_users = scope.joins(:user)

          students_with_users.where("users.name ILIKE ?", "%#{search}%").or(
            students_with_users.where("users.email ILIKE ?", "%#{search}%")
          )
        else
          scope
        end
      end
  end

  def allow_token_auth?
    true
  end
end
