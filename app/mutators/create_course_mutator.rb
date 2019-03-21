class CreateCourseMutator < ApplicationMutator
  attr_accessor :name
  attr_accessor :max_grade
  attr_accessor :pass_grade
  attr_accessor :grades_and_labels
  attr_accessor :ends_at

  validates :name, presence: true
  validates :max_grade, presence: true
  validates :pass_grade, presence: true
  validates :grades_and_labels, presence: true
  validates :ends_at, presence: true

  def correct_grades_and_labels
    return if max_grade == grades_and_labels.count

    raise "UpdateCourseMutator received invalid grades and labels #{grades_and_labels}"
  end

  def create_course
    Course.create!(name: name, school: current_school, max_grade: max_grade, pass_grade: pass_grade, grade_labels: grade_labels, ends_at: ends_at)
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      [grades_and_label[:grade].to_s, grades_and_label[:label]]
    end.to_h
  end
end
