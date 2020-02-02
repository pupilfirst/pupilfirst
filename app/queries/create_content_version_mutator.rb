class CreateContentVersionMutator < ApplicationQuery
  include AuthorizeAuthor

  property :target_id, validates: { presence: true }

  validate :target_exists

  def target_exists
    errors[:base] << 'Target does not exist' if target.blank?
  end

  def create
    ::Targets::UpdateService.new(target).execute(target_params)
  end

  private

  def target
    @target ||= current_school.targets.where(id: id).first
  end

  def course
    @course ||= target&.course
  end

  def latest_content_version_date
    return if content_versions.empty?

    content_versions.maximum(:version_on)
  end

  def current_content_blocks
    return if content_versions.empty?

    ContentBlock.where(id: content_versions.where(version_on: latest_content_version_date).select(:content_block_id))
  end

  def latest_content_versions
    return if content_versions.empty?

    content_versions.where(version_on: latest_content_version_date)
  end
end
