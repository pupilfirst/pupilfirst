class InboundWebhooks::BecknController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  # POST /inbound_webhook/beckn
  def create
    record = InboundWebhook.create(body: payload, school: current_school)
    InboundWebhooks::BecknJob.perform_later(record)

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
    # Also add authentication for the Beckn webhook; Waiting on https://github.com/beckn/protocol-server/issues/152
    head :unauthorized unless beckn_config.configured?
  end

  def payload
    @payload ||= request.body.read
  end

  def beckn_config
    @beckn_config ||= Schools::Configuration::Beckn.new(current_school)
  end
end
