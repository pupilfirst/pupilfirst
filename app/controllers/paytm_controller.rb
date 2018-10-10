class PaytmController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :callback

  # GET /paytm/pay
  def pay
    render layout: false
  end

  # TODO: Configure PayTM's callback_url to point here. Now using a temporary 'home#paytm_callback'
  # POST /paytm/callback
  def callback
    # There's nothing to load.
  end
end
