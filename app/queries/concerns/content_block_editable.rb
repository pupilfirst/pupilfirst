module ContentBlockEditable
  include ActiveSupport::Concern

  def resource_school
    course&.school
  end

  def course
    @course ||= target&.level&.course
  end

  def target
    @target ||= content_block&.target_version&.target
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: id)
  end

  def json_attributes
    attributes = content_block.attributes
      .slice('id', 'block_type', 'content', 'sort_index')
      .with_indifferent_access

    if content_block.file.attached?
      attributes[:content].merge!(
        url: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true),
        filename: content_block.file.filename.to_s,
      )
    end

    attributes
  end

  def target_version
    @target_version ||= target.current_target_version
  end

  def content_blocks
    @content_blocks ||= target_version.content_blocks
  end

  def must_be_latest_version
    return if content_blocks.where(id: id).present?

    errors[:base] << 'You can only edit blocks in the current version.'
  end
end
