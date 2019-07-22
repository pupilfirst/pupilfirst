module Schools
  module Targets
    class CreateContentBlockForm < Reform::Form
      property :block_type, validates: { presence: true, inclusion: { in: ContentBlock.valid_block_types } }
      property :target_id, validates: { presence: true }
      property :url, virtual: true
      property :content_sort_indices, virtual: true, validates: { presence: true }
      property :file, virtual: true
      property :markdown, virtual: true
      property :title, virtual: true
      property :caption, virtual: true

      validates :file, presence: true, image: true, file_size: { less_than: 5.megabytes }, if: :image_block?
      validates :file, presence: true, file_size: { less_than: 10.megabytes }, if: :file_block?
      validates :markdown, presence: true, if: :markdown_block?
      validates :url, presence: true, if: :embed_block?

      def save
        ::ContentBlocks::CreateService.new(target, content_block_params).execute
      end

      private

      def target
        Target.find(target_id)
      end

      def image_block?
        block_type == ContentBlock::BLOCK_TYPE_IMAGE
      end

      def file_block?
        block_type == ContentBlock::BLOCK_TYPE_FILE
      end

      def markdown_block?
        block_type == ContentBlock::BLOCK_TYPE_MARKDOWN
      end

      def embed_block?
        block_type == ContentBlock::BLOCK_TYPE_EMBED
      end

      def content_block_params
        {
          block_type: block_type,
          target_id: target_id,
          url: url,
          content_sort_indices: content_sort_indices,
          file: file,
          markdown: markdown,
          title: title,
          caption: caption
        }
      end
    end
  end
end
