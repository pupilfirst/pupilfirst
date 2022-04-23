class UpdateMarkdownContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :markdown, validates: { length: { maximum: ContentBlock.markdown_curriculum_editor_max_length } }

  validate :must_be_a_markdown_block
  validate :must_be_latest_version

  def update_markdown_content_block
    content_block.update!(content: { markdown: markdown.strip })
    target_version.touch # rubocop:disable Rails/SkipsModelValidations
    json_attributes.tap do |results|
      results["content"].merge!(curriculum_editor_max_length)
    end
  end

  private

  def curriculum_editor_max_length
    { "curriculum_editor_max_length" => ContentBlock.markdown_curriculum_editor_max_length }
  end

  def must_be_a_markdown_block
    return if content_block.markdown?

    errors[:base] << 'This is not a markdown block'
  end
end
