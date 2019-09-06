class ReviewedSubmissionsResolver < ApplicationResolver
  def collection(course_id, level_id)
    if authorized?(course_id)
      submissions(course_id, level_id).evaluated_by_faculty.includes(:startup_feedback, founders: :user, target: :target_group).order("updated_at DESC")
    else
      TimelineEvent.none
    end
  end

  def authorized?(course_id)
    current_user.faculty.courses.where(id: course_id).present?
  end

  def submissions(course_id, level_id)
    if level_id.present?
      Course.find(course_id).levels.where(id: level_id).first.timeline_events
    else
      Course.find(course_id).timeline_events
    end
  end
end
