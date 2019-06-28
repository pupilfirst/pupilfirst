class CreateTargetMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :title
  attr_accessor :target_group_id

  validates :title, presence: { message: 'TitleBlank' }
  validates :target_group_id, presence: { message: 'TargetGroupIdBlank' }

  def create_target
    target = Target.create!(title: title, target_group_id: target_group_id, role: 'founder', target_action_type: 'Todo', visibility: Target::VISIBILITY_DRAFT, safe_to_change_visibility: true)
    content_block = ContentBlock.create!(target: target, block_type: 'markdown', sort_index: 1, content: { markdown: content_block_text })
    { id: target.id, content_block_id: content_block.id, sample_content: content_block_text }
  end

  def content_block_text
    "## Markdown editor\n\nYou can create your target text content using this editor. Use the preview button to get a \
    feel of the generated content. Here is a basic guide to format content using markdown:\n\n## HEADERS\n\n# This is an \
    h1 header\n## This is an h2 header\n###### This is an h6 header\n\n\n\n## EMPHASIS\n\n*This text will be italic*\n_This \
    will also be italic_\n**This text will be bold**\n__This will also be bold__\n\n\n\n## LINKS\n\nhttp://github.com - \
    automatic!\n[GitHub](http://github.com)\n\n\n\n## CODE BLOCKS\n\n\n```javascript\nfunction test() \
    {\n console.log('this is generated using markdown');\n}\n```\n\n\n\n## LISTS\n\nUnordered:\n* Item 1\n* Item 2\n   \
    * Item 2a\n   * Item 2b\n\nOrdered:\n1. Item 1\n2. Item 2\n3. Item 3\n    * Item 3a\n    * Item 3b\n\nRefer to \
    [Markdown Guide](https://www.markdownguide.org/cheat-sheet) for more information.\n"
  end
end
