class ContentBlockResolver < ApplicationQuery
  property :target_id
  property :version_at

  validate :target_version_must_be_valid

  def content_blocks
    if version_at.present?
      content_data(target_version.content_blocks)
    else
      content_data(target.current_content_blocks)
    end
  end

  private

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  def target_version_must_be_valid
    return if version_at.nil? || target_version.present?

    errors[:base] << 'Target version does not exist'
  end

  def target_version
    target.target_versions.find_by(version_at: version_at.in_time_zone)
  end

  def target
    @target ||= Target.find(target_id.to_i)
  end

  def file_details(content_block)
    { url: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true), filename: content_block.file.filename.to_s }
  end

  def content_data(content_blocks)
    content_blocks.with_attached_file.map do |content_block|
      content_block_data = content_block.attributes.slice('id', 'block_type', 'content', 'sort_index')
      content_block_data.merge!(file_details(content_block)) if content_block.file.attached?
      content_block_data.symbolize_keys
    end
  end
end
