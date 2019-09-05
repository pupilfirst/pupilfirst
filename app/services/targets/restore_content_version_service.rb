module Targets
  class RestoreContentVersionService
    def initialize(target, version_on)
      @target = target
      @version_on = version_on
    end

    def execute
      ContentBlock.transaction do
        delete_todays_version
        duplicate_requested_version
      end
    end

    private

    def content_versions
      ContentVersion.where(target: @target, version_on: @version_on)
    end

    def latest_content_version_date
      @latest_content_version_date ||= @target.latest_content_version_date
    end

    def content_blocks_created_today
      @content_blocks_created_today ||= begin
        current_blocks = ContentBlock.where(id: ContentVersion.where(target: @target, version_on: latest_content_version_date).pluck(:content_block_id))
        ids_to_delete = current_blocks.map do |cb|
          next unless cb.created_at.to_date == Date.today

          cb.id
        end.compact
        ContentBlock.where(id: ids_to_delete)
      end
    end

    def delete_todays_version
      return unless latest_content_version_date == Date.today

      blocks_to_delete = content_blocks_created_today
      @target.latest_content_versions.destroy_all
      blocks_to_delete.destroy_all
    end

    def duplicate_requested_version
      content_versions.each do |version|
        new_version = version.dup
        new_version.save!
        new_version.update!(version_on: Date.today)
      end
    end
  end
end
