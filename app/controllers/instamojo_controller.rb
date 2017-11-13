class InstamojoController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :authenticate_webhook_request, only: :webhook

  # GET /instamojo/redirect?payment_request_id&payment_id
  def redirect
    payment = Payment.find_by instamojo_payment_request_id: params[:payment_request_id]
    payment.refresh_payment!(params[:payment_id])

    # Ensure that the call to this route is for a payment that is in 'Credited' payment state.
    if payment.instamojo_payment_status != Instamojo::PAYMENT_STATUS_CREDITED
      raise "Unexpected payment request status #{payment.instamojo_payment_request_status} for redirected Payment ##{payment.id}"
    end

    # Log payment time, if unrecorded.
    if payment.paid_at.blank?
      payment.paid_at = Time.zone.now
      payment.save!
    end

    if payment.startup.level_zero?
      Admissions::PostPaymentService.new(payment: payment).execute
    else
      Founders::PostPaymentService.new(payment).execute
    end

    flash[:success] = 'Your payment has been recorded.'
    redirect_to dashboard_founder_path(from: 'instamojo_redirect')
  end

  # POST /instamojo/webhook
  def webhook
    payment = Payment.find_by instamojo_payment_request_id: params[:payment_request_id]

    payment.instamojo_payment_id = params[:payment_id]
    payment.instamojo_payment_status = params[:status]
    payment.fees = params[:fees]
    payment.webhook_received_at = Time.zone.now

    if params[:status] == Instamojo::PAYMENT_STATUS_CREDITED
      payment.instamojo_payment_request_status = Instamojo::PAYMENT_REQUEST_STATUS_COMPLETED
      payment.paid_at = Time.zone.now if payment.paid_at.blank?
    end

    payment.save!

    if payment.paid?
      if payment.startup.level_zero?
        Admissions::PostPaymentService.new(payment: payment).execute
      else
        Founders::PostPaymentService.new(payment).execute
      end
    end

    head :ok
  end

  private

  def authenticate_webhook_request
    salt = Rails.application.secrets.instamojo_salt
    data = (params.keys - %w[controller action mac]).sort.map { |key| params[key] }.join '|'
    digest = OpenSSL::Digest.new('sha1')
    computed_mac = OpenSSL::HMAC.hexdigest(digest, salt, data)

    head(:unauthorized) if params[:mac] != computed_mac
  end
end
