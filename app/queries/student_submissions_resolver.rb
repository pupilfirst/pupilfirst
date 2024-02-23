class StudentSubmissionsResolver < ApplicationQuery
  property :student_id
  property :status
  property :sort_direction

  def student_submissions
    applicable_submissions
      .includes(target: :assignments)
      .distinct
      .order("timeline_events.created_at #{sort_direction_string}")
  end

  def authorized?
    return false if current_user.blank?

    return false if student&.school != current_school

    return false if student.blank?

    return true if current_user.id == student.user_id

    return true if current_school_admin.present?

    student.course.faculty.exists?(user: current_user)
  end

  def applicable_submissions
    submissions_by_student = student.timeline_events.live.not_auto_verified

    filter_by_status(status, submissions_by_student)
  end

  def student
    @student ||= Student.find_by(id: student_id)
  end

  def filter_by_status(status, submissions)
    case status
    when "PendingReview"
      submissions.where(evaluated_at: nil)
    when "Completed"
      submissions.passed
    when "Rejected"
      submissions.failed
    when nil
      submissions
    else
      raise "Unexpected status '#{status}' encountered when resolving submissions"
    end
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
end
