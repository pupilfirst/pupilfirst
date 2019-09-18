class ConvertStartupFeedbackToMarkdown < ActiveRecord::Migration[5.2]
  def replace_divs(html)
    html.gsub(/<div>\n?/, '').gsub(/<\/div>\n?/, '<br/>').gsub(' \n', '<br/>')
  end

  def up
    StartupFeedback.all.each do |feedback|
      puts "Processing StartupFeedback##{feedback.id}..."

      markdown_feedback = Kramdown::Document.new(replace_divs(feedback.feedback), input: 'html').to_kramdown
      feedback.update!(feedback: markdown_feedback)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
