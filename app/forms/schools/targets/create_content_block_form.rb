module Schools
  module Targets
    class CreateContentBlockForm < Reform::Form
      property :block_type, validates: { presence: true, inclusion: { in: %w[image file] } }
      property :target_id, virtual: true, validates: { presence: true }
      property :file, virtual: true
      property :above_content_block_id, virtual: true

      validates :file, presence: true, image: true, file_size: { less_than: 5.megabytes }, if: :image_block?
      validates :file, presence: true, file_size: { less_than: 10.megabytes }, if: :file_block?

      def save
        ContentBlock.transaction do
          content_block = create_file_or_image_block
          shift_content_blocks_below(content_block)
          json_attributes(content_block)
        end
      end

      private

      def create_file_or_image_block
        target_version.content_blocks.create!(
          block_type: block_type,
          content: content(block_type),
          file: file,
          sort_index: sort_index,
        )
      end

      def content(block_type)
        filename = file.original_filename

        case block_type
        when 'image'
          { caption: filename, width: 'Auto' }
        when 'file'
          { title: filename }
        else
          raise "Unexpected block type #{block_type} encountered when creating file-based content block for target with ID #{target_id}"
        end
      end

      def target
        Target.find(target_id)
      end

      def target_version
        @target_version ||= target.current_target_version
      end

      def image_block?
        block_type == ContentBlock::BLOCK_TYPE_IMAGE
      end

      def file_block?
        block_type == ContentBlock::BLOCK_TYPE_FILE
      end

      def above_content_block
        @above_content_block ||= begin
            target.content_blocks.find_by(id: above_content_block_id) if above_content_block_id.present?
          end
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
            filename: content_block.file.filename.to_s,
          )
        else
          attributes
        end
      end
    end
  end
end
