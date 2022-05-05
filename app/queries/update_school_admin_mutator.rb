class UpdateSchoolAdminMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id
  property :name, validates: { presence: true, length: { maximum: 128 } }

  validate :record_must_exists

  def save
    school_admin.user.update!(name: name)
  end

  private

  def resource_school
    school_admin&.school
  end

  def record_must_exists
    return if school_admin.present?

    errors[:base] << 'IncorrectSchoolAdminId'
  end

  def school_admin
    @school_admin ||= SchoolAdmin.find_by(id: id)
  end
end
