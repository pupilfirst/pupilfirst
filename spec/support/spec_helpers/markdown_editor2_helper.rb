module MarkdownEditor2Helper
  def replace_markdown(markdown)
    editor = find("textarea[aria-label='Markdown editor']")
    editor.click
    editor.send_keys(*delete_sequence(editor), markdown)
  end

  def add_markdown(markdown)
    editor = find("textarea[aria-label='Markdown editor']")
    editor.click
    editor.send_keys(markdown)
  end

  private

  def delete_sequence(editor)
    if (/darwin/ =~ RUBY_PLATFORM).present?
      # The :command key doesn't work on OSX + Chrome.
      ([:backspace] * editor.text.length)
    else
      [[:control, 'a'], :delete]
    end
  end
end
