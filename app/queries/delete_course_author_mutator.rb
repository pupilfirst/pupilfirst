class DeleteCourseAuthorMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  validate :must_be_author_in_this_school

  def delete_course_author
    course_author.destroy!
  end

  private

  def must_be_author_in_this_school
    return if course_author.present?

    errors[:base] << 'The ID that was supplied is invalid'
  end

  def course_author
    CourseAuthor.joins(user: :school).where(schools: { id: current_school.id }).find_by(id: id)
  end
end
