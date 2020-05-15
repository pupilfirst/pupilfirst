class UpdateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  include CourseEditable

  property :id

  validate :course_must_be_present

  def course_must_be_present
    return if course.present?

    errors[:base] << "Could not find a course with ID #{id}"
  end

  def update_course
    course.update!(
      name: name,
      description: description,
      ends_at: ends_at,
      public_signup: public_signup,
      about: about,
      featured: featured,
      progression_behavior: progression_behavior,
      progression_limit: sanitized_progression_limit,
    )

    course
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: id)
  end
end
