class UpdateCourseMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
  property :description, validates: { presence: true, length: { minimum: 1, maximum: 150 } }
  property :ends_at
  property :public_signup
  property :about, validates: { length: { maximum: 10_000 } }
  property :featured

  validate :valid_course_id

  def valid_course_id
    return if course.present?

    raise "UpdateCourseMutator received non-existent course ID #{id}"
  end

  def update_course
    @course.update!(
      name: name,
      description: description,
      ends_at: ends_at,
      public_signup: public_signup,
      about: about,
      featured: featured
    )
    @course
  end

  private

  def course
    @course ||= current_school.courses.find_by(id: id)
  end
end
