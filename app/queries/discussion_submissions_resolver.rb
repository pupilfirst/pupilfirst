class DiscussionSubmissionsResolver < ApplicationQuery
  property :target_id
  property :pinned

  def discussion_submissions
    student =
      current_user
        .students
        .joins(:course)
        .where(courses: { id: @course.id })
        .first if current_user.present?
    submissions =
      course
        .timeline_events
        .not_auto_verified
        .live
        .joins(:students)
        .where.not(students: { id: student })

    # Filter by target
    if course.targets.exists?(id: target_id)
      submissions.where(target_id: target_id)
    else
      submissions
    end
  end

  #TODO use correct authorization for students
  def authorized?
    return false if course&.school != current_school

    return true if current_school_admin.present?

    return false if coach.blank?

    coach.courses.exists?(id: course)
  end

  def course
    @course ||= Target.find_by(id: target_id).course
  end

  def allow_token_auth?
    true
  end
end
