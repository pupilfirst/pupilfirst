class CreateSchoolAdminMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :email, validates: { presence: true, length: { maximum: 128 }, email: true }
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :not_a_school_admin

  def create_school_admin
    SchoolAdmin.transaction do
      current_admins = current_school.school_admins.load
      user = persisted_user || User.create!(email: email, school: current_school, title: 'School Admin')
      user.update!(name: name)
      new_school_admin = SchoolAdmin.create!(user: user, school: current_school)

      current_admins.each do |admin|
        SchoolAdminMailer.school_admin_added(admin, new_school_admin).deliver_later
      end

      new_school_admin
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
