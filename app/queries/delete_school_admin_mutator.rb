class DeleteSchoolAdminMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  validate :must_be_admin_of_this_school
  validate :at_least_one_admin_must_exist

  def delete_school_admin
    school_admin.destroy!
  end

  private

  def resource_school
    school_admin&.school
  end

  def must_be_admin_of_this_school
    return if school_admin.present?

    errors[:base] << 'The ID that was supplied is invalid'
  end

  def at_least_one_admin_must_exist
    return if current_school.school_admins.count > 1

    errors[:base] << 'Your school must have at least one admin'
  end

  def school_admin
    @school_admin ||= SchoolAdmin.find_by(id: id)
  end
end
