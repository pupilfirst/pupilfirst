class StudentSubmissionsResolver < ApplicationQuery
  property :student_id
  property :level_id
  property :status
  property :sort_direction

  def student_submissions
    applicable_submissions.includes(target: :level).distinct.order("timeline_events.created_at #{sort_direction_string}")
  end

  def authorized?
    return false if current_user.blank?

    return false if student.blank?

    return true if current_user.id == student.user_id

    coach.present? && coach.courses.exists?(id: student.course)
  end

  def applicable_submissions
    submissions_by_student = student.timeline_events.not_auto_verified

    by_level = if level_id.present?
        submissions_by_student.where(levels: { id: level_id })
      else
        submissions_by_student
      end

    if status.present?
      filter_by_status(status, by_level)
    else
      by_level
    end
  end

  def student
    @student ||= Founder.find_by(id: student_id)
  end

  def coach
    @coach ||= current_user.faculty
  end

  def filter_by_status(status, submissions)
    case status
    when 'PendingReview'
      submissions.where(evaluated_at: nil)
    when 'Completed'
      submissions.passed
    when 'Rejected'
      submissions.failed
    else
      raise "Unexpected status '#{status}' encountered when resolving submissions"
    end
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
end
