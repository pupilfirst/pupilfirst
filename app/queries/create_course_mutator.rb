class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 2, maximum: 50 } }
  property :description, validates: { presence: true, length: { minimum: 2, maximum: 150 } }
  property :ends_at
  property :public_signup
  property :about, validates: { length: { maximum: 10_000 } }
  property :featured

  def correct_grades_and_labels
    return if @course.max_grade == (grade_labels.values - [""]).count

    raise "CreateCourseMutator received invalid grades and labels #{grades_and_labels}"
  end

  def create_course
    Course.transaction do
      course = Course.create!(
        name: name, description: description,
        school: current_school,
        ends_at: ends_at,
        public_signup: public_signup,
        about: about,
        featured: featured
      )
      Courses::DemoContentService.new(course).execute
      course
    end
  end
end
