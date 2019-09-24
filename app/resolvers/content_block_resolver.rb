class ContentBlockResolver < ApplicationResolver
  attr_accessor :target_id
  attr_accessor :version_date

  def content_blocks
    if version_date.present?
      content_data(target.content_versions.where(version_on: version_date))
    else
      latest_content
    end
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  def target
    @target ||= Target.find(target_id.to_i)
  end

  def latest_content
    latest_version_date = target.content_versions.maximum(:version_on)
    latest_content_versions = target.content_versions.where(version_on: latest_version_date)
    content_data(latest_content_versions)
  end

  def file_details(content_block)
    { url: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true), filename: content_block.file.filename.to_s }
  end

  def content_data(content_versions)
    ContentBlock.where(
      id: content_versions.select(:content_block_id)
    ).with_attached_file.map do |content_block|
      content_block_data = content_block.attributes.slice('id', 'block_type', 'content').merge(content_versions.find_by(content_block: content_block).slice('sort_index'))
      content_block_data.merge!(file_details(content_block)) if content_block.file.attached?
      content_block_data.symbolize_keys
    end
  end
end
