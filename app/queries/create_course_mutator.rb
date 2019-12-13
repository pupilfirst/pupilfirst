class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: true, length: { minimum: 2, maximum: 50 } }
  property :description, validates: { presence: true, length: { minimum: 2, maximum: 150 } }
  property :max_grade, validates: { presence: { message: 'MaxGradeBlank' } }
  property :pass_grade, validates: { presence: { message: 'PassGradeBlank' } }
  property :grades_and_labels, validates: { presence: { message: 'GradesAndLabelsBlank' } }
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
        max_grade: max_grade,
        pass_grade: pass_grade,
        grade_labels: grade_labels,
        ends_at: ends_at,
        public_signup: public_signup,
        about: about,
        featured: featured
      )
      Courses::DemoContentService.new(course).execute
      course
    end
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      [grades_and_label[:grade].to_s, grades_and_label[:label].strip]
    end.to_h
  end
end
