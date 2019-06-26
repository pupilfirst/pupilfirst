module Schools
  module Targets
    class CreateContentBlockForm < Reform::Form
      property :block_type, validates: { presence: true }
      property :target_id, validates: { presence: true }
      property :url, virtual: true
      property :sort_index, validates: { presence: true }
      property :text, virtual: true
      property :file, virtual: true

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
