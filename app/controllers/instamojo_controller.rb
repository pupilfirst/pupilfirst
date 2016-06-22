class InstamojoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  # POST /instamojo/initiate_payment/:id
  def initiate_payment
    batch_application = BatchApplication.find_by id: params[:id]
    raise_not_found if batch_application.blank? || batch_application.paid?
    @payment = Payment.find_or_create_by!(batch_application: batch_application)

    if Rails.env.production?
      redirect_to @payment.long_url
    else
      render text: "Redirect to #{@payment.long_url}"
    end
  end

  # GET /instamojo/redirect?payment_request_id&payment_id
  def redirect
    payment = Payment.find_by instamojo_payment_request_id: params[:payment_request_id]
    payment.refresh_payment!(params[:payment_id])
    payment.batch_application.peform_post_payment_tasks!

    redirect_to apply_batch_path(batch: payment.batch_application.batch.id)
  end

  # POST /instamojo/webhook
  def webhook
    return unless authentic_request?
    payment = Payment.find_by instamojo_payment_request_id: params[:payment_request_id]

    payment.update(
      instamojo_payment_id: params[:payment_id],
      instamojo_payment_status: params[:status],
      fees: params[:fees]
    )

    payment.batch_application.peform_post_payment_tasks!

    render nothing: true
  end

  protected

  def authentic_request?
    salt = APP_CONFIG[:instamojo][:salt]
    data = (params.keys - %w(controller action mac)).sort.map { |key| params[key] }.join '|'
    digest = OpenSSL::Digest.new('sha1')
    computed_mac = OpenSSL::HMAC.hexdigest(digest, salt, data)

    return true if params[:mac] == computed_mac

    head :unauthorized
    false
  end
end
