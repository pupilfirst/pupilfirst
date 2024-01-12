class AddMarkdownForVisitLinkTargets < ActiveRecord::Migration[7.0]
  class Target < ApplicationRecord
    has_many :target_versions

    def current_target_version
      target_versions.order(created_at: :desc).first
    end
  end

  class TargetVersion < ApplicationRecord
    belongs_to :target
    has_many :content_blocks
  end

  class ContentBlock < ApplicationRecord
    belongs_to :target_version

    BLOCK_TYPE_EMBED = -"embed"
    BLOCK_TYPE_MARKDOWN = -"markdown"
  end

  def up
    possibly_affected_content_blocks =
      ContentBlock
        .joins(target_version: :target)
        .where(block_type: ContentBlock::BLOCK_TYPE_EMBED)
        .where("content_blocks.content->>'url' = targets.link_to_complete")

    possibly_affected_content_blocks.find_each do |content_block|
      # Remove last_resolved_at.
      content_block.content = content_block.content.except("last_resolved_at")
      content_block.save!

      # Re-resolve the content block.
      embed_code =
        ContentBlocks::ResolveEmbedCodeService.new(content_block).execute

      # If the resulting embed_code is nil, change this to a markdown block
      if embed_code.nil?
        content_block.block_type = ContentBlock::BLOCK_TYPE_MARKDOWN

        content_block.content = {
          url: content_block.content["url"],
          markdown:
            "Visit the following link to complete this target: #{content_block.content["url"]}"
        }

        content_block.save!
      end
    end
  end

  def down
    # This was a data migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
