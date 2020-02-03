class CreateTargetVersionMutator < ApplicationQuery
  property :target_id
  property :version_at

  validate :target_version_must_be_valid
  validate :target_exists

  def create_target_version
    ::TargetVersions::CreateService.new(target, target_version).execute
  end

  private

  def target_version_must_be_valid
    return if version_at.nil? || target_version.present?

    errors[:base] << 'Target version does not exist'
  end

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def target
    @target ||= current_school.targets.find_by(id: target_id)
  end

  def target_version
    @target_version ||= target.target_versions.find_by(version_at: version_at)
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end
end
