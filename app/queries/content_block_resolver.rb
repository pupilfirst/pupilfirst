class ContentBlockResolver < ApplicationQuery
  property :target_id
  property :version_at

  def content_blocks
    if version_at.present?
      content_data(target.target_versions.where(version_at: version_at).first.content_blocks)
    else
      content_data(target.current_content_blocks)
    end
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  private

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
