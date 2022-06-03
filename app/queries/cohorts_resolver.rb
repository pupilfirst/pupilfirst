class CohortsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :search

  def cohorts
    if search.present?
      course.cohorts.where('name ILIKE ?', "%#{search}%")
    else
      course.cohorts
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
  end
end
