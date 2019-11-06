class ReviewedSubmissionsResolver < ApplicationQuery
  property :course_id
  property :level_id

  def reviewed_submissions
    submissions.evaluated_by_faculty.includes(:startup_feedback, founders: :user, target: :target_group).order("created_at DESC")
  end

  def authorized?
    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: course).exists?
  end

  def course
    @course ||= Course.find(course_id)
  end

  def submissions
    if level_id.present?
      course.levels.where(id: level_id).first.timeline_events
    else
      course.timeline_events
    end.from_founders(students)
  end

  def students
    @students ||= Founder.where(startup_id: current_user.faculty.reviewable_startups(course))
  end
end
