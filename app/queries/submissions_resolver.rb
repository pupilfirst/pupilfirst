class SubmissionsResolver < ApplicationQuery
  property :course_id
  property :status
  property :sort_direction
  property :sort_criterion
  property :level_id
  property :personal_coach_id
  property :assigned_coach_id
  property :target_id
  property :search
  property :exclude_submission_id
  property :include_inactive

  def submissions
    applicable_submissions.distinct.order(
      "#{sort_criterion_string} #{sort_direction_string}"
    )
  end

  def authorized?
    return false if current_user.faculty.blank?

    current_user.faculty.courses.exists?(id: course)
  end

  def sort_direction_string
    case sort_direction
    when 'Ascending'
      'ASC'
    when 'Descending'
      'DESC'
    else
      raise "#{sort_direction} is not a valid sort direction"
    end
  end

  def sort_criterion_string
    case sort_criterion
    when 'SubmittedAt'
      'created_at'
    when 'EvaluatedAt'
      'evaluated_at'
    else
      raise "#{sort_criterion} is not a valid sort criterion"
    end
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def applicable_submissions
    stage_1 =
      if course.levels.exists?(id: level_id)
        course.levels.find_by(id: level_id).timeline_events.not_auto_verified
      else
        course.timeline_events.not_auto_verified
      end

    stage_2 =
      if course.targets.exists?(id: target_id)
        stage_1.where(target_id: target_id)
      else
        stage_1
      end

    stage_3 = filter_by_status(stage_2)

    stage_4 =
      if course.faculty.exists?(id: personal_coach_id)
        stage_3
          .joins(founders: { startup: :faculty_startup_enrollments })
          .where(faculty_startup_enrollments: { faculty_id: personal_coach_id })
      else
        stage_3
      end

    stage_5 =
      if course.faculty.exists?(id: assigned_coach_id)
        stage_4.where(reviewer: assigned_coach_id)
      else
        stage_4
      end

    final_list =
      if exclude_submission_id.present?
        stage_5.where.not(id: exclude_submission_id)
      else
        stage_5
      end

    final_list.from_founders(students)
  end

  def filter_by_status(submissions)
    return submissions if status.blank?

    case status
    when 'Pending'
      submissions.pending_review
    when 'Reviewed'
      submissions.evaluated_by_faculty
    else
      raise "Unexpected status '#{status}' encountered when resolving submissions"
    end
  end

  def teams
    @teams ||=
      (include_inactive ? course.startups : course.startups.active).joins(
        founders: :user
      )
  end

  def course_teams
    if search.present?
      teams
        .where('users.name ILIKE ?', "%#{search}%")
        .or(teams.where('startups.name ILIKE ?', "%#{search}%"))
        .or(teams.where('users.email ILIKE ?', "%#{search}%"))
    else
      teams
    end
  end

  def students
    @students ||= Founder.where(startup_id: course_teams)
  end

  def allow_token_auth?
    true
  end
end
