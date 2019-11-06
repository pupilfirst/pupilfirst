class DestroySchoolLinkMutator < ApplicationQuery
  property :id, validates: { presence: true }

  def destroy_school_link
    school_link.destroy!
  end

  def school_link
    @school_link ||= current_school.school_links.find_by(id: id)
  end

  def authorized?
    current_school_admin.present? && school_link.present?
  end
end
