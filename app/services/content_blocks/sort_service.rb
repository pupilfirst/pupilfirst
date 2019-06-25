module ContentBlocks
  class SortService
    def initialize(content_block_ids)
      @content_block_ids = content_block_ids
    end

    def execute
      raise 'Content blocks does not belong to the same target' unless ContentBlock.where(id: @content_block_ids).pluck(:target_id).uniq.one?

      @content_block_ids.each_with_index do |id, index|
        ContentBlock.find(id).update!(sort_index: index + 1)
      end
    end
  end
end
