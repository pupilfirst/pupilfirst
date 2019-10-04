module MarkdownAttachments
  class EmbedCodeService
    def initialize(markdown_attachment, view_context)
      @markdown_attachment = markdown_attachment
      @view_context = view_context
    end

    def embed_code
      code = "[#{filename}](#{url})"
      @markdown_attachment.image? ? "!#{code}" : code
    end

    private

    def url
      @view_context.download_markdown_attachment_url(id: @markdown_attachment, token: @markdown_attachment.token)
    end

    def filename
      @markdown_attachment.file.filename
    end
  end
end
