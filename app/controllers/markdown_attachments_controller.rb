class MarkdownAttachmentsController < ApplicationController
  before_action :authenticate_user!, only: %i[create]

  # POST /markdown_attachments
  def create
    form = MarkdownAttachments::CreateForm.new(authorize(MarkdownAttachment.new))
    form.current_user = current_user

    if form.validate(params[:markdown_attachment])
      markdown_attachment = form.save
      embed_code = MarkdownAttachments::EmbedCodeService.new(markdown_attachment, view_context).embed_code
      render json: { errors: [], markdownEmbedCode: embed_code }
    else
      render json: { errors: form.errors.full_messages }
    end
  end

  # GET /:id/:token
  def download
    markdown_attachment = authorize(MarkdownAttachment.where(token: params[:token]).find(params[:id]))
    markdown_attachment.update!(last_accessed_at: Time.zone.now)
    redirect_to view_context.url_for(markdown_attachment.file)
  end
end
