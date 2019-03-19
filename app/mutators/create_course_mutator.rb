class CreateCourseMutator < ApplicationMutator
  attr_accessor :name
  attr_accessor :max_grade
  attr_accessor :pass_grade

  validates :name, presence: true
  validates :max_grade, presence: true
  validates :pass_grade, presence: true

  def create_course
    Course.create!(name: name, school: current_school, max_grade: max_grade, pass_grade: pass_grade)
  end
end
