class RestoreContentVersionMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :target_id, validates: { presence: true }
  property :version_on, validates: { presence: true }

  def restore
    ::Targets::RestoreContentVersionService.new(target, version_on).execute
  end

  private

  def target
    Target.find(target_id)
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end
end
