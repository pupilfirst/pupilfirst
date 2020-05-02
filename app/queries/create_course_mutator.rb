class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin
  include CourseEditable

  def create_course
    Course.transaction do
      course = Course.create!(
        name: name, description: description,
        school: current_school,
        ends_at: ends_at,
        public_signup: public_signup,
        about: about,
        featured: featured,
        progression_behavior: progression_behavior,
        progression_limit: sanitized_progression_limit
      )

      Courses::DemoContentService.new(course).execute

      course
    end
  end
end
