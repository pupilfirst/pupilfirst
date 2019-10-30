class CreateSchoolAdminMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  attr_accessor :name
  attr_accessor :email

  validates :email, presence: true, length: { maximum: 128 }, email: true
  validates :name, presence: true, length: { maximum: 128 }

  validate :not_a_school_admin

  def save
    SchoolAdmin.transaction do
      user = persisted_user || User.create!(email: email, school: current_school, title: 'School Admin')
      user.update!(name: name)
      SchoolAdmin.create!(user: user, school: current_school)
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
