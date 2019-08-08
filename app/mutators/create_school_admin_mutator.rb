class CreateSchoolAdminMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :name
  attr_accessor :email

  validates :email, presence: true, length: { maximum: 128 }, email: true
  validates :name, presence: true, length: { maximum: 128 }

  validate :not_a_school_admin

  def school_admin
    return if courses.count == course_ids.count

    errors[:base] << 'IncorrectCourseIds'
  end

  def save
    SchoolAdmin.transaction do
      user = persisted_user || User.create!(email: email, school: current_school, name: name)
      SchoolAdmin.create!(user: user, school: current_school)
      user.avatar
    end
  end

  private

  def not_a_school_admin
    return if persisted_user.blank?

    return if persisted_user.school_admin.blank?

    errors[:base] << "Already enrolled as admin"
  end

  def persisted_user
    @persisted_user ||= current_school.users.with_email(email).first
  end
end
