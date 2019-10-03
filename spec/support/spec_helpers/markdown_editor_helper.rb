module MarkdownEditorHelper
  def replace_markdown(markdown)
    find('div[contenteditable="true"]').set(markdown)
  end

  def add_markdown(markdown)
    editor = find('div[contenteditable="true"]')
    editor.click
    editor.send_keys(markdown)
  end
end
