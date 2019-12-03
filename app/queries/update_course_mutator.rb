class UpdateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { presence: { message: 'NameBlank' } }
  property :description, validates: { presence: { message: 'DescriptionBlank' } }
  property :grades_and_labels, validates: { presence: { message: 'GradesAndLabelsBlank' } }
  property :ends_at
  property :public_signup
  property :about
  property :featured

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
      public_signup: public_signup,
      about: about,
      featured: featured
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
    @course ||= current_school.courses.find_by(id: id)
  end
end
