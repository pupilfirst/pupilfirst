class CreateTargetMutator < ApplicationMutator
  include AuthorizeSchoolAdmin

  attr_accessor :title
  attr_accessor :target_group_id

  validates :title, presence: { message: 'TitleBlank' }
  validates :target_group_id, presence: { message: 'TargetGroupIdBlank' }

  def create_target
    target = Target.create!(title: title, target_group_id: target_group_id, role: 'founder', target_action_type: 'Todo', visibility: Target::VISIBILITY_DRAFT, safe_to_change_visibility: true, sort_index: sort_index)
    content_block = ContentBlock.create!(target: target, block_type: 'markdown', sort_index: 1, content: { markdown: content_block_text })
    { id: target.id, content_block_id: content_block.id, sample_content: content_block_text }
  end

  def content_block_text
    <<~PREVIEW_CONTENT
      ## Markdown editor

      You can create your target text content using this editor. Use the preview button to get a feel of the generated content. Here is a basic guide to format content using markdown:

      ## Headings

      # This is a Level 1 heading
      ### This is a Level 3 heading
      ###### This is a Level 6 heading

      ## Emphasis

      *This text will be italic.*

      _This will also be italic._

      **This text will be bold.**

      __This will also be bold.__

      ## Links

      This is how you link to [GitHub](http://github.com).

      ## Code blocks

      ```javascript
      function test()     {
       console.log('This is generated using markdown.');
      }
      ```

      ## Lists

      Un-ordered:

      * Item 1
      * Item 2
        * Item 2a
        * Item 2b

      Ordered:

      1. Item 1
      2. Item 2
      3. Item 3
          1. Item 3.1
          2. Item 3.2

      Please refer to [Markdown Guide](https://commonmark.org/help) for more information.
    PREVIEW_CONTENT
  end

  def sort_index
    max_index = TargetGroup.joins(:course).where(courses: { school_id: current_school.id }).find(target_group_id).targets.maximum(:sort_index)
    max_index ? max_index + 1 : 1
  end
end
