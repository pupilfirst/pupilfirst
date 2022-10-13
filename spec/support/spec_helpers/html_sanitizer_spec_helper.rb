module HtmlSanitizerSpecHelper
  def sanitize_html(html)
    sanitized =
      Rails::Html::FullSanitizer
        .new
        .sanitize(html)
        .squeeze(' ')
        .gsub(/(\r\n\s?)+/, "\n")
        .squeeze("\n")

    CGI.unescape_html(sanitized)
  end
end
