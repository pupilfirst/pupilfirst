class ErrorsController < ApplicationController
  include Gaffe::Errors

  # Render this page even if authenticity token checks fail.
  skip_before_filter :verify_authenticity_token
end
