class ReviewSubmissionDetailsResolver < ApplicationResolver
  def collection(submission_id)
    submission = TimelineEvent.find_by(id: submission_id)
    if authorized?(submission)
      TimelineEvent.where(target_id: submission.target_id).includes(:timeline_event_owners).where(timeline_event_owners: { founder_id: submission.founders.pluck(:id) })
    else
      TimelineEvent.none
    end
  end

  def authorized?(submission)
    return false if submission.blank?

    current_user.faculty.courses.where(id: submission.target.course.id).present?
  end
end
