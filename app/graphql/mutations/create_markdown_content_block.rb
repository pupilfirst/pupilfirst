module Mutations
  class CreateMarkdownContentBlock < ApplicationQuery
    include QueryAuthorizeAuthor
    include ContentBlockCreatable

    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false

    description 'Creates a markdown content block.'

    field :content_block, Types::ContentBlockType, null: true

    def resolve(_params)
      { content_block: create_markdown_content_block }
    end

    def create_markdown_content_block
      ContentBlock.transaction do
        markdown_block = create_markdown_block
        shift_content_blocks_below(markdown_block)
        target_version.touch # rubocop:disable Rails/SkipsModelValidations
        json_attributes(markdown_block)
      end
    end

    def create_markdown_block
      target_version.content_blocks.create!(
        sort_index: sort_index,
        block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
        content: {
          markdown: ''
        }
      )
    end
  end
end
