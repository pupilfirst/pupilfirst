module ContentBlockCreatable
  include ActiveSupport::Concern

  def resource_school
    course&.school
  end

  def course
    @course ||= target.level.course if target.present?
  end

  def target
    @target ||= Target.find_by(id: @params[:target_id])
  end

  def target_version
    @target_version ||= target.current_target_version
  end

  def above_content_block
    @above_content_block ||=
      begin
        if @params[:above_content_block_id].present?
          content_blocks.find_by(id: @params[:above_content_block_id])
        end
      end
  end

  def shift_content_blocks_below(content_block)
    content_blocks
      .where.not(id: content_block.id)
      .where('sort_index >= ?', sort_index)
      .update_all('sort_index = sort_index + 1') # rubocop:disable Rails/SkipsModelValidations
  end

  def sort_index
    @sort_index ||=
      if above_content_block.present?
        # Put at the same position as 'above_content_block'.
        above_content_block.sort_index
      else
        # Put at the bottom.
        content_blocks.maximum(:sort_index) + 1
      end
  end

  def json_attributes(content_block)
    attributes =
      content_block
        .attributes
        .slice('id', 'block_type', 'content', 'sort_index')
        .with_indifferent_access

    if content_block.file.attached?
      attributes.merge(
        fileUrl:
          Rails.application.routes.url_helpers.rails_public_blob_url(
            content_block.file
          ),
        filename: content_block.file.filename.to_s
      )
    else
      attributes
    end
  end

  def content_blocks
    @content_blocks ||= target_version.content_blocks
  end
end
