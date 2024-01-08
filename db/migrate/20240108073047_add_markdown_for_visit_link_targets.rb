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
    Target.find_each do |target|
      if target.link_to_complete.present?
        target_version = target.current_target_version
        last_content_block =
          target_version.content_blocks.order(sort_index: :desc).first

        #Only add markdown if the last block is an embed block
        if last_content_block.block_type == ContentBlock::BLOCK_TYPE_EMBED
          last_content_block.delete
          target_version.content_blocks.create(
            block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
            content: {
              markdown:
                "Visit the following link to complete this target: #{target.link_to_complete}"
            },
            sort_index: target_version.content_blocks.maximum(:sort_index) + 1
          )
        else
          next
        end
      else
        next
      end
    end
  end
end
