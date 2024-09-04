class InboundWebhooks::BecknController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  # POST /inbound_webhook/beckn
  def create
    record = InboundWebhook.create!(body: payload)
    InboundWebhooks::ProcessBecknRequestJob.perform_later(record)

    head :ok,
         json: {
           context: payload["context"],
           message: {
             ack: {
               status: "ACK"
             }
           }
         }
  end

  private

  def verify_signature
    return if secret.blank?

    auth_header = request.headers["authorization"]&.strip

    if auth_header.blank?
      return(
        render json: {
                 message: "Missing authorization header"
               },
               status: :unauthorized
      )
    end

    unless auth_header.starts_with?("HMAC-SHA-256")
      return(
        render json: {
                 message: "Invalid signature format"
               },
               status: :unauthorized
      )
    end

    received_hmac = auth_header.split.last
    expected_hmac = hmac(secret, payload)

    unless ActiveSupport::SecurityUtils.secure_compare(
             received_hmac,
             expected_hmac
           )
      return(
        render json: { message: "Invalid signature" }, status: :unauthorized
      )
    end
  end

  def payload
    @payload ||= request.body.read
  end

  def secret
    @secret ||= Settings.beckn[:webhook_hmac_key]
  end

  def hmac(secret, payload)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
  end
end
