module Schools
  module Targets
    class CreateContentBlockForm < Reform::Form
      property :block_type, validates: { presence: true }
      property :target_id, validates: { presence: true }
      property :url, virtual: true
      property :content_sort_indices, virtual: true, validates: { presence: true }
      property :file, virtual: true, validates: { file_size: { less_than: 10.megabytes } }

      validate :image_block_must_have_image_file
      validate :file_required_for_image_and_file_blocks

      def image_block_must_have_image_file
        return if block_type != ContentBlock::BLOCK_TYPE_IMAGE

        return if file.present? && file.content_type.in?(['image/jpeg', 'image/png', 'image/gif'])

        errors[:base] << 'Image content must be JPG, PNG or GIF'
      end

      def file_required_for_image_and_file_blocks
        return if block_type.in? [ContentBlock::BLOCK_TYPE_EMBED, ContentBlock::BLOCK_TYPE_MARKDOWN]
        return if file.present?

        errors[:base] << 'File attachment missing from content'
      end

      def save(content_block_params)
        ::ContentBlocks::CreateService.new(target, content_block_params).execute
      end

      private

      def target
        Target.find(target_id)
      end
    end
  end
end
