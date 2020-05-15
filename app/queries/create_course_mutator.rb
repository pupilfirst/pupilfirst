class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  include CourseEditable

  def create_course
    Course.transaction do
      course = current_school.courses.create!(
        name: name, description: description,
        ends_at: ends_at,
        public_signup: public_signup,
        about: about,
        featured: featured,
        progression_behavior: progression_behavior,
        progression_limit: sanitized_progression_limit,
      )

      Courses::DemoContentService.new(course).execute

      course
    end
  end

  private

  def resource_school
    current_school
  end
end
