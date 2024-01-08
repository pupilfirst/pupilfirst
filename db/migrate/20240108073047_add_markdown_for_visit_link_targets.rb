class AddMarkdownForVisitLinkTargets < ActiveRecord::Migration[7.0]
  class Target < ApplicationRecord
    has_many :target_versions, dependent: :destroy

    def current_target_version
      target_versions.order(created_at: :desc).first
    end
  end

  class TargetVersion < ApplicationRecord
    belongs_to :target
    has_many :content_blocks, dependent: :destroy
  end

  class ContentBlock < ApplicationRecord
    belongs_to :target_version

    BLOCK_TYPE_EMBED = -"embed"
    BLOCK_TYPE_MARKDOWN = -"markdown"
  end

  def change
    Target
      .where.not(link_to_complete: nil)
      .find_each do |target|
        target_version = target.current_target_version
        latest_embed_content_block =
          target_version
            .content_blocks
            .where(block_type: ContentBlock::BLOCK_TYPE_EMBED)
            .order(sort_index: :desc)
            .first

        #Convert the latest embed block to a markdown block
        if latest_embed_content_block &&
             latest_embed_content_block.content[:url] == target.link_to_complete
          latest_embed_content_block.block_type =
            ContentBlock::BLOCK_TYPE_MARKDOWN
          latest_embed_content_block.content = {
            markdown:
              "Visit the following link to complete this target: #{target.link_to_complete}"
          }
          latest_embed_content_block.save
        else
          next
        end
      end
  end
end
