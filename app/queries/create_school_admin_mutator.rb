class CreateSchoolAdminMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :email, validates: { presence: true, length: { maximum: 128 }, email: true }
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :not_a_school_admin

  def create_school_admin
    SchoolAdmin.transaction do
      user = persisted_user || current_school.users.create!(email: email, title: 'School Admin')
      user.update!(name: name)
      new_school_admin = current_school.school_admins.create!(user: user)

      current_school.school_admins.where.not(user_id: user.id).each do |admin|
        SchoolAdminMailer.school_admin_added(admin, new_school_admin).deliver_later
      end

      create_audit_record(user)
      new_school_admin
    end
  end

  private

  def resource_school
    current_school
  end

  def not_a_school_admin
    return if persisted_user.blank?

    return if persisted_user.school_admin.blank?

    errors[:base] << 'Already enrolled as admin'
  end

  def persisted_user
    @persisted_user ||= current_school.users.with_email(email).first
  end

  def create_audit_record(user)
    AuditRecord.create!(audit_type: AuditRecord::TYPE_ADD_SCHOOL_ADMIN, school_id: current_school.id, metadata: { user_id: current_user.id, email: user.email })
  end
end
