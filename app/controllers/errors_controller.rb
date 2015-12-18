class ErrorsController < ApplicationController
  include Gaffe::Errors

  # Make sure anonymous users can see the page
  skip_before_filter :authenticate_user!

  # Render the correct template based on the exception "standard" code.
  # Eg. For a 404 error, the `errors/not_found` template will be rendered.
  def show
    expires_in(5.minutes, public: true) if @status_code == 404

    # Here, the `@exception` variable contains the original raised error
    render "errors/#{@rescue_response}", status: @status_code
  end
end
