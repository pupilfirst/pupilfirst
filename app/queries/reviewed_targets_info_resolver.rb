class ReviewedTargetsInfoResolver < ApplicationQuery
  include AuthorizeCoach

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

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end

  def applicable_reviewed_targets
    course.targets.live.joins(:evaluation_criteria)
  end
end
