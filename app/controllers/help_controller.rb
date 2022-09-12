class HelpController < ApplicationController
  before_action :validate_document

  # GET /help/:document
  def show
    @markdown = Rails.root.join('docs', 'served', document_filename).read
    render layout: 'student'
  end

  private

  def document_filename
    @document_filename ||= params[:document] == "markdown_editor" ? "markdown_editor.md" : nil
  end

  def validate_document
    raise_not_found if document_filename.blank?
  end
end
