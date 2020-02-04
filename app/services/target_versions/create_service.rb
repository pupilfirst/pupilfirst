module TargetVersions
  class CreateService
    def initialize(target, target_version)
      @target = target
      @target_version = target_version
    end

    def execute
      content_blocks = @target.current_content_blocks
      target_version = target_version.presence || @target.target_versions.create!
      copy_content_blocks(content_blocks, target_version)
    end

    private

    def copy_content_blocks(content_blocks, target_version)
      content_blocks.each do |old_content_block|
        new_content_block = old_content_block.dup
        new_content_block.target_version_id = target_version.id
        new_content_block.save!
        new_content_block.file.attach(old_content_block.file.blob) if old_content_block.file.attached?
      end
    end
  end
end
