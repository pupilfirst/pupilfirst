class CreateMarkdownContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :above_content_block_id

  def create_markdown_content_block
    ContentBlock.transaction do
      markdown_block = create_markdown_block
      Targets::CreateContentVersionService.new(target, above_content_block).create(markdown_block)
    end
  end

  private

  def create_markdown_block
    ContentBlock.create!(
      block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
      content: { markdown: "" }
    )
  end
end
