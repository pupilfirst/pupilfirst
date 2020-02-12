module ContentBlocks
  class DemoMarkdownBlockService
    def initialize(target)
      @target = target
    end

    def execute
      ContentBlock.transaction do
        target_version = @target.target_versions.create!
        content_block = ContentBlock.create!(
          block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
          content: { markdown: content_block_text },
          sort_index: 1,
          target_version: target_version
        )
        content_block
      end
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
  end
end
