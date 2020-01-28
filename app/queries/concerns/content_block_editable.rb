module ContentBlockEditable
  include ActiveSupport::Concern

  def course
    target.level.course if target.present?
  end

  def target
    @target ||= begin
      if content_block.present?
        content_block.latest_version.target
      end
    end
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: id)
  end

  def json_attributes
    attributes = content_block.attributes
      .slice('id', 'block_type', 'content')
      .merge(content_version.slice('sort_index'))
      .with_indifferent_access

    if content_block.file.attached?
      attributes[:content].merge!(
        url: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true),
        filename: content_block.file.filename.to_s
      )
    end

    attributes
  end

  def content_version
    @content_version ||= target.content_versions.find_by(content_block: content_block, version_on: latest_version_date)
  end

  def latest_version_date
    @latest_version_date ||= target.latest_content_version_date
  end
end
