module HtmlSanitizerSpecHelper
  def sanitize_html(html)
    Rails::Html::FullSanitizer.new.sanitize(html).squeeze(' ').gsub(/(\r\n\s?)+/, "\n").squeeze("\n")
  end
end
