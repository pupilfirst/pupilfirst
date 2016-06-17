class InstamojoController < ApplicationController
  # POST /instamojo/initiate_payment/:id
  def initiate_payment
    batch_application = BatchApplication.find_by id: params[:id]
    raise_not_found if batch_application.blank? || batch_application.paid?
    @payment = Payment.find_or_create_by!(batch_application: batch_application)
    # redirect_to @payment.long_url
    render text: "Redirect to #{@payment.long_url}"
  end

  # GET /instamojo/redirect
  def redirect
    raise NotImplementedError
  end

  # GET /instamojo/webhook
  def webhook
    raise NotImplementedError
  end
end
