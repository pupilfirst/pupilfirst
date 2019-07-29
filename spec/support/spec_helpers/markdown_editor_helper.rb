module MarkdownEditorHelper
  def replace_markdown(markdown)
    find('div[contenteditable="true"]').set(markdown)
  end
end
