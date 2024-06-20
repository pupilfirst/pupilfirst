class InboundWebhooks::BecknController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :verify_signature

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
    # TODO: Add authentication for the Beckn webhook; Waiting on https://github.com/beckn/protocol-server/issues/152
  end

  def payload
    @payload ||= request.body.read
  end
end
