module TargetVersions
  class CreateService
    def initialize(target)
      @target = target
    end

    def execute
      content_blocks = @target.current_content_blocks
      target_version = @target.content_version.create!(version_at: DateTime.now)
      copy_content_blocks(content_blocks, target_version)
    end

    private

    def copy_content_blocks(content_blocks, target_version)
      content_blocks.each do |content_block|
        new_content_block = content_block.dup
        new_content_block.target_versions_id = target_version.id
      end
    end
  end
end
