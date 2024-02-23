class DiscussionSubmissionsResolver < ApplicationQuery
  property :target_id

  def discussion_submissions
    # add moderator to context to be used in type fields
    context[:moderator] = moderator?
    submissions =
      course
        .timeline_events
        .discussion_enabled
        .live
        .joins(:students)
        .where.not(students: { id: student })

    # Filter by target
    submissions =
      submissions.where(target_id: target_id) if course.targets.exists?(
      id: target_id
    )

    #Filter hidden submissions if not moderator
    submissions = submissions.not_hidden unless moderator?

    submissions.order(pinned: :desc, created_at: :desc)
  end

  def authorized?
    return false if current_user.blank?

    return false if course&.school != current_school

    return true if current_school_admin.present?

    return true if current_user.course_authors.where(course: course).present?

    return true if course.faculty.exists?(user: current_user)

    student.present?
  end

  def moderator?
    current_school_admin.present? || @course.faculty.exists?(user: current_user)
  end

  def student
    @student ||=
      current_user
        .students
        .joins(:cohort)
        .find_by(cohorts: { course_id: course })
  end

  def course
    @course ||= target&.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end
end
