module MarkdownEditorHelper
  def replace_markdown(markdown, id: nil)
    add_markdown(markdown, replace: true, id: id)
  end

  def add_markdown(markdown, replace: false, id: nil)
    editor =
      if id.present?
        find('#' + id)
      else
        find("textarea[aria-label='Markdown editor']")
      end
    editor.click

    if replace
      editor.send_keys(*delete_sequence(editor), markdown)
    else
      editor.send_keys(markdown)
    end
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
