module Targets
  class ContentDataService
    def initialize(target)
      @target = target
    end

    def details
      {
        quiz_questions: quiz_questions,
        content_blocks: content_blocks,
        content_versions: content_versions,
        latest_content_version: @target.latest_content_version&.id
      }
    end

    private

    def content_blocks
      @target.content_blocks.with_attached_file.map do |content_block|
        cb = content_block.attributes.slice('id', 'block_type', 'content', 'sort_index')
        if content_block.file.attached?
          cb['file_url'] = url_helpers.rails_blob_path(content_block.file, only_path: true)
          cb['filename'] = content_block.file.filename
        end
        cb
      end
    end

    def content_versions
      return if @target.target_content_versions.blank?

      @target.target_content_versions.map do |version|
        version.attributes.slice('id', 'target_id', 'content_blocks', 'updated_at')
      end
    end
  end
end
