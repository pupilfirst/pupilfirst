class UpdateMarkdownContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :markdown, validates: { length: { maximum: 10_000 } }

  validate :must_be_a_markdown_block

  # TODO: Implement an equivalent of this when target_versions table is present.
  # validate :must_be_latest_version

  def update_markdown_content_block
    content_block.update!(content: { markdown: markdown.strip })
    json_attributes
  end

  private

  def must_be_a_markdown_block
    return if content_block.markdown

    errors[:base] << 'This is not a markdown block'
  end
end
