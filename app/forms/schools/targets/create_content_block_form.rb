module Schools
  module Targets
    class CreateContentBlockForm < Reform::Form
      property :block_type, validates: { presence: true }
      property :target_id, validates: { presence: true }
      property :url, virtual: true
      property :sort_index, validates: { presence: true }
      property :text, virtual: true
      property :file, virtual: true, validates: { file_size: { less_than: 10.megabytes } }

      validate :image_block_must_have_image_file

      def image_block_must_have_image_file
        return if block_type != ContentBlock::BLOCK_TYPE_IMAGE

        return if file.content_type.in? ['image/jpeg', 'image/png', 'image/gif']

        errors[:base] << 'Image content must be JPG, PNG or GIF'
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
