module ContentBlocks
  class SortService
    def initialize(content_block_ids)
      @content_block_ids = content_block_ids
    end

    def execute
      ContentBlock.transaction do
        if latest_version_date == Date.today
          @content_block_ids.each_with_index do |id, index|
            ContentVersion.where(content_block_id: id, version_on: Date.today).last.update!(sort_index: index + 1)
          end
        else
          create_new_content_version
        end
      end
    end

    private

    def latest_version_date
      @latest_version_date ||= target.content_versions.maximum(:version_on)
    end

    def target
      @target ||= ContentVersion.where(content_block_id: @content_block_ids).first.target
    end

    def create_new_content_version
      @content_block_ids.each_with_index do |id, index|
        ContentVersion.create!(target: target, content_block_id: id, sort_index: index + 1, version_on: Date.today)
      end
    end
  end
end
