class ReviewedSubmissionsResolver < ApplicationResolver
  def collection(course_id, page)
    if authorized?(course_id)
      Course.find(course_id).timeline_events.evaluated_by_faculty.includes(:startup_feedback, founders: :user, target: :target_group).page(page.to_i).per(30)
    else
      TimelineEvent.none
    end
  end

  def authorized?(course_id)
    current_user.faculty.courses.where(id: course_id).present?
  end
end
