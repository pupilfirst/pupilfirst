class ErrorsController < ApplicationController
  include Gaffe::Errors

  # Render this page even if authenticity token checks fail.
  skip_before_action :verify_authenticity_token

  # Only respond with HTML or JSON, regardless of what is asked for.
  before_action :override_format

  def show
    respond_to do |format|
      format.html { render "errors/#{@rescue_response}", status: @status_code }
      format.json { render json: { error: @status_code }, status: @status_code }
    end
  end

  # GET /errors/:error_type
  def simulate
    valid_types = %w[internal_server_error not_acceptable not_found unprocessable_entity]

    if params[:error_type].in?(valid_types)
      render "errors/#{params[:error_type]}"
    else
      raise ":error_type should be one of #{valid_types.join(', ')}"
    end
  end

  private

  # We want requests for images and all other general content (pdf, doc, etc) to be treated as html requests.
  def override_format
    request.format = 'html' unless params[:format] == 'json'
  end
end
