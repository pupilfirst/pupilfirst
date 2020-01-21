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
          image_block = create_image_block
          ::Targets::CreateContentVersionService.new(target, above_content_block).create(image_block)
        end
      end

      private

      def create_image_block
        ContentBlock.create!(
          block_type: block_type,
          content: content(block_type),
          file: file
        )
      end

      def content(block_type)
        filename = file.original_filename

        case block_type
          when 'image'
            { caption: filename }
          when 'file'
            { title: filename }
          else
            raise "Unexpected block type #{block_type} encountered when creating file-based content block for target with ID #{target_id}"
        end
      end

      def target
        Target.find(target_id)
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
    end
  end
end
