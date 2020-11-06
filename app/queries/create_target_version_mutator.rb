class CreateTargetVersionMutator < ApplicationQuery
  property :target_version_id

  validate :target_version_must_be_valid
  validate :target_exists
  validate :content_should_change
  validate :less_than_three_versions_per_day

  def create_target_version
    ::TargetVersions::CreateService.new(target, target_version).execute
  end

  private

  def authorized?
    return false if current_user.blank?

    return false if target&.course&.school != current_school

    current_school_admin.present? || current_user.course_authors.exists?(course: target.course)
  end

  def target_version_must_be_valid
    return if target_version_id.nil? || target_version.present?

    errors[:base] << 'Target version does not exist'
  end

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def less_than_three_versions_per_day
    return if target.target_versions.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).count < 3

    errors[:base] << 'You cannot create more than 3 versions per day'
  end

  def content_should_change
    return if target_version.blank?

    return if target.target_versions.count == 1 || target.current_target_version.id != target_version.id

    return if target_version.created_at.to_i != target_version.updated_at.to_i

    errors[:base] << 'There are no changes from the previous version. Please make changes before trying to save this version.'
  end

  def target
    target_version&.target
  end

  def target_version
    @target_version ||= TargetVersion.find_by(id: target_version_id)
  end
end
