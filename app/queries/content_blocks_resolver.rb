class ContentBlocksResolver < ApplicationQuery
  property :target_id
  property :target_version_id

  def content_blocks
    if target_version.present?
      content_data(target_version.content_blocks)
    else
      content_data(target.current_content_blocks)
    end
  end

  private

  def authorized?
    return false if target&.course&.school != current_school

    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  def target_version
    target.target_versions.find_by(id: target_version_id)
  end

  def target
    @target ||= Target.find_by(id: target_id)
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
