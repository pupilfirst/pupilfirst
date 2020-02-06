module Targets
  class UpdateSortIndexService
    def initialize(target, above_content_block)
      @target = target
      @above_content_block = above_content_block
    end

    def update(content_block)
      shift_content_blocks_below(content_block)
      json_attributes(content_block)
    end

    def sort_index
      @sort_index ||= begin
        if above_content_block.present?
          # Put at the same position as 'above_content_block'.
          above_content_block.sort_index
        else
          # Put at the bottom.
          content_blocks.maximum(:sort_index) + 1
        end
      end
    end

    private

    def target_version
      @target_version ||= @target.current_target_version
    end

    def content_blocks
      target_version.content_blocks
    end

    def shift_content_blocks_below(content_block)
      content_blocks.where.not(id: content_block.id).where('sort_index >= ?', sort_index)
        .update_all('sort_index = sort_index + 1') # rubocop:disable Rails/SkipsModelValidations
    end

    def json_attributes(content_block)
      attributes = content_block.attributes
        .slice('id', 'block_type', 'content', 'sort_index')
        .with_indifferent_access

      if content_block.file.attached?
        attributes.merge(
          fileUrl: Rails.application.routes.url_helpers.rails_blob_path(content_block.file, only_path: true),
          filename: content_block.file.filename.to_s
        )
      else
        attributes
      end
    end
  end
end
