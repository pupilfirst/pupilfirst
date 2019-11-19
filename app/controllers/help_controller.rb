class HelpController < ApplicationController
  before_action :validate_document

  # GET /help/:document
  def show
    @markdown = File.read(Rails.root.join('docs', 'served', document_filename))
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
