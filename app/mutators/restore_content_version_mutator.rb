class RestoreContentVersionMutator < ApplicationMutator
  include AuthorizeSchoolAdmin
  attr_accessor :version_on
  attr_accessor :target_id

  validates :target_id, presence: true
  validates :version_on, presence: true

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
