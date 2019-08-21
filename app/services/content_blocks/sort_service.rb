module ContentBlocks
  class SortService
    def initialize(content_block_ids)
      @content_block_ids = content_block_ids
    end

    def execute
      raise 'Content blocks does not belong to the same target' unless ContentBlock.where(id: @content_block_ids).pluck(:target_id).uniq.one?

      if latest_content_version.updated_at.to_date == Date.today
        @content_block_ids.each_with_index do |id, index|
          ContentBlock.find(id).update!(sort_index: index + 1)
        end
      else
        create_new_content_version
      end
    end

    private

    def latest_content_version
      @latest_content_version ||= target.target_content_versions.order('updated_at desc').first
    end

    def target
      @target ||= ContentBlock.where(id: @content_block_ids).first.target
    end

    def create_new_content_version
      new_content_block_ids = []

      @content_block_ids.each_with_index do |id, index|
        current_block = ContentBlock.find(id)
        new_content_block = current_block.dup
        new_content_block.save!
        new_content_block.update!(sort_index: index + 1)
        new_content_block.file.attach(current_block.file.blob) if current_block.file.attached?
        new_content_block_ids << new_content_block.id
      end

      target.target_content_versions.create!(content_blocks: new_content_block_ids)
    end
  end
end
