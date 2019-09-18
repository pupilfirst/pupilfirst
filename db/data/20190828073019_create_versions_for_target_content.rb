class CreateVersionsForTargetContent < ActiveRecord::Migration[5.2]
  def up
    Target.all.each do |target|
      content_blocks = ContentBlock.where(target_id: target.id)
      next if content_blocks.blank?
      content_blocks.each do |content_block|
        ContentVersion.create!(target: target, content_block: content_block, sort_index: content_block.sort_index, version_on: Date.today)
      end
    end
  end

  def down
    ContentVersion.destroy_all
  end
end
