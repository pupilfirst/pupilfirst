class CreateCourseAuthorMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id, validates: { presence: true }
  property :email, validates: { presence: true, length: { maximum: 128 }, email: true }
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :course_must_be_present
  validate :not_a_course_author
  validate :not_be_an_admin

  def create_course_author
    CourseAuthor.transaction do
      user = persisted_user || User.create!(email: email, school: current_school, title: 'Author')
      user.update!(name: name)
      course_author = course.course_authors.create!(user: user)
      user.regenerate_login_token if user.login_token.blank?
      CourseAuthorMailer.addition(course_author).deliver_later
      course_author
    end
  end

  private

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def course_must_be_present
    return if course.present?

    errors[:base] << 'The supplied ID is invalid'
  end

  def not_a_course_author
    return if course.blank?

    return unless course.course_authors.joins(:user).pluck('users.email').include?(email)

    errors[:base] << 'Already enrolled as author'
  end

  def not_be_an_admin
    return if persisted_user&.school_admin.blank?

    errors[:base] << 'This user is already a school admin'
  end

  def persisted_user
    @persisted_user ||= current_school.users.with_email(email).first
  end
end
