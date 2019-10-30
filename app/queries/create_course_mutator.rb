class CreateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  attr_accessor :name
  attr_accessor :max_grade
  attr_accessor :pass_grade
  attr_accessor :grades_and_labels
  attr_accessor :ends_at
  attr_accessor :description
  attr_accessor :enable_leaderboard
  attr_accessor :public_signup
  attr_accessor :about

  validates :name, presence: { message: 'NameBlank' }
  validates :max_grade, presence: { message: 'MaxGradeBlank' }
  validates :pass_grade, presence: { message: 'PassGradeBlank' }
  validates :grades_and_labels, presence: { message: 'GradesAndLabelsBlank' }
  validates :description, presence: { message: 'DescriptionBlank' }

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
