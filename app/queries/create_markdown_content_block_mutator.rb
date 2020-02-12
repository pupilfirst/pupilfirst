class CreateMarkdownContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :above_content_block_id

  def create_markdown_content_block
    ContentBlock.transaction do
      markdown_block = create_markdown_block
      shift_content_blocks_below(markdown_block)
      target_version.touch # rubocop:disable Rails/SkipsModelValidations
      json_attributes(markdown_block)
    end
  end

  private

  def create_markdown_block
    target_version.content_blocks.create!(
      sort_index: sort_index,
      block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
      content: { markdown: "" }
    )
  end
end
