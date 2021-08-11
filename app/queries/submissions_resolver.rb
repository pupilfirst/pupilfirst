class SubmissionsResolver < ApplicationQuery
  property :course_id
  property :status
  property :sort_direction
  property :sort_criterion
  property :level_id
  property :coach_id
  property :target_id
  property :search
  property :exclude_submission_id

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
    by_level =
      if level_id.present?
        course
          .levels
          .where(id: level_id)
          .first
          .timeline_events
          .not_auto_verified
      else
        course.timeline_events.not_auto_verified
      end

    by_level_and_target =
      target_id.present? ? by_level.where(target_id: target_id) : by_level

    by_level_and_status = filter_by_status(by_level_and_target)

    by_level_status_and_coach =
      if coach_id.present?
        by_level_and_status
          .joins(founders: { startup: :faculty_startup_enrollments })
          .where(faculty_startup_enrollments: { faculty_id: coach_id })
      else
        by_level_and_status
      end

    final_list =
      if exclude_submission_id.present?
        by_level_status_and_coach.where.not(id: exclude_submission_id)
      else
        by_level_status_and_coach
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
    @teams ||= course.startups.active.joins(founders: :user)
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
