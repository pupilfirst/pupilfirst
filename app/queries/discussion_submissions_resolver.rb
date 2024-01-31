class DiscussionSubmissionsResolver < ApplicationQuery
  property :target_id

  def discussion_submissions
    submissions =
      course
        .timeline_events
        .discussion_enabled
        .not_hidden
        .live
        .joins(:students)
        .where.not(students: { id: student })

    # Filter by target
    submissions =
      submissions.where(target_id: target_id) if course.targets.exists?(
      id: target_id
    )

    submissions.order(pinned: :desc)
  end

  def authorized?
    return false if current_user.blank?

    # Has access to school
    return false unless student&.school == current_school

    # school admin or course author
    if current_school_admin.present? ||
         current_user.course_authors.where(course: course).present?
      return true
    end

    return true if current_user.id == student.user_id

    current_user.faculty&.cohorts&.exists?(id: student.cohort_id)
  end

  def student
    @student ||=
      current_user
        .students
        .joins(:cohort)
        .where(cohorts: { course_id: course })
        .first
  end

  def course
    @course ||= target&.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def allow_token_auth?
    true
  end
end
