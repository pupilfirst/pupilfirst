class UpdateCourseAuthorMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :author_must_exist

  def update_course_author
    course_author.user.update!(name: name)
  end

  private

  def resource_school
    course_author&.user&.school
  end

  def author_must_exist
    return if course_author.present?

    errors[:base] << 'Supplied ID is invalid'
  end

  def course_author
    @course_author ||= CourseAuthor.find_by(id: id)
  end
end
