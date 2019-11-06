class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :name, validates: { presence: { message: 'NameBlank' } }
  property :max_grade, validates: { presence: { message: 'MaxGradeBlank' } }
  property :pass_grade, validates: { presence: { message: 'PassGradeBlank' } }
  property :grades_and_labels, validates: { presence: { message: 'GradesAndLabelsBlank' } }
  property :description, validates: { presence: { message: 'DescriptionBlank' } }
  property :ends_at
  property :enable_leaderboard
  property :public_signup
  property :about

  def correct_grades_and_labels
    return if max_grade == grades_and_labels.count

    raise "UpdateCourseMutator received invalid grades and labels #{grades_and_labels}"
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
        enable_leaderboard: enable_leaderboard,
        public_signup: public_signup,
        about: about
      )
      Courses::DemoContentService.new(course).execute
      course
    end
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      [grades_and_label[:grade].to_s, grades_and_label[:label]]
    end.to_h
  end
end
