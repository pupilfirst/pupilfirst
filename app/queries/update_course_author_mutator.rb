class UpdateCourseAuthorMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :author_must_exist

  def update_course_author
    course_author.user.update!(name: name)
  end

  private

  def author_must_exist
    return if course_author.present?

    errors[:base] << 'Supplied ID is invalid'
  end

  def course_author
    @course_author ||= CourseAuthor.joins(user: :school).where(schools: { id: current_school }).find_by(id: id)
  end
end
