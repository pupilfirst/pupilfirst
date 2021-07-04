class ReviewedTargetsInfoResolver < ApplicationQuery
  property :search
  property :course_id

  def reviewed_targets_info
    if search.present?
      applicable_reviewed_targets.where('title ILIKE ?', "%#{search}%")
    else
      applicable_reviewed_targets
    end
  end

  private

  def authorized?
    return false if course.blank?

    current_coach.present?
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def applicable_reviewed_targets
    course.targets.live.joins(:evaluation_criteria)
  end
end
