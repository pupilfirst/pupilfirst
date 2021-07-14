class LevelsResolver < ApplicationQuery
  include AuthorizeCoach

  property :search
  property :course_id

  def levels
    if search.present?
      applicable_levels.where('name ILIKE ?', "%#{search}%")
    else
      applicable_levels
    end
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end

  def applicable_levels
    course.levels
  end
end
