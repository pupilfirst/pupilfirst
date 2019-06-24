class UpdateCourseMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :id
  attr_accessor :name
  attr_accessor :grades_and_labels
  attr_accessor :ends_at
  attr_accessor :description
  attr_accessor :enable_leaderboard

  validates :name, presence: { message: 'NameBlank' }
  validates :description, presence: { message: 'DescriptionBlank' }
  validates :grades_and_labels, presence: { message: 'GradesAndLabelsBlank' }

  validate :valid_course_id
  validate :correct_grades_and_labels

  def valid_course_id
    return if course.present?

    raise "UpdateCourseMutator received non-existent course ID #{id}"
  end

  def correct_grades_and_labels
    return if @course.max_grade == grades_and_labels.count

    raise "UpdateCourseMutator received invalid grades and labels #{grades_and_labels}"
  end

  def update_course
    @course.update!(
      name: name,
      description: description,
      grade_labels: grade_labels,
      ends_at: ends_at,
      enable_leaderboard: enable_leaderboard
    )
    @course
  end

  private

  def grade_labels
    grades_and_labels.map do |grades_and_label|
      [grades_and_label[:grade].to_s, grades_and_label[:label]]
    end.to_h
  end

  def course
    @course ||= Course.find_by(id: id)
  end
end
