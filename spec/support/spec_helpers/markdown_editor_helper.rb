module MarkdownEditorHelper
  def replace_markdown(markdown, id: nil)
    add_markdown(markdown, replace: true, id: id)
  end

  def add_markdown(markdown, replace: false, id: nil)
    editor = id.present? ? find('#' + id) : find("textarea[aria-label='Markdown editor']")
    editor.click

    if replace
      editor.send_keys(*delete_sequence(editor), markdown)
    else
      editor.send_keys(markdown)
    end
  end

  private

  def delete_sequence(editor)
    ([:backspace] * editor.text.length)
  end
end
