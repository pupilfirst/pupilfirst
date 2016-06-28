class ErrorsController < ApplicationController
  include Gaffe::Errors

  # Render this page even if authenticity token checks fail.
  skip_before_action :verify_authenticity_token
end
