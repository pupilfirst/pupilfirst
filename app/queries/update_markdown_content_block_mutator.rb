class UpdateMarkdownContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :markdown,
           validates: {
             length: {
               maximum:
                 Settings.markdown_curriculum_editor_max_length
             }
           }

  validate :must_be_a_markdown_block
  validate :must_be_latest_version

  def update_markdown_content_block
    content_block.update!(content: { markdown: markdown.strip })
    target_version.touch # rubocop:disable Rails/SkipsModelValidations
    json_attributes
  end

  private

  def must_be_a_markdown_block
    return if content_block.markdown?

    errors.add(:base, 'This is not a markdown block')
  end
end
