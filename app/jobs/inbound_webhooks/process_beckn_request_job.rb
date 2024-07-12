require "net/http"
require "json"

module InboundWebhooks
  class ProcessBecknRequestJob < ApplicationJob
    queue_as :default

    def perform(inbound_webhook)
      inbound_webhook.processing!
      begin
        payload = JSON.parse(inbound_webhook.body)
        action = payload["context"]["action"]
        service_class = service(action)

        if service_class.present?
          data = service_class.new(payload).execute
          response =
            Beckn::RespondService.new(payload).execute("on_#{action}", data)
          handle_response(response, inbound_webhook)
        else
          inbound_webhook.failed!
        end
      rescue JSON::ParserError => e
        Rails.logger.error(
          "Failed to parse the JSON payload: #{e.message}, Webhook ID: #{inbound_webhook.id}",
        )
        inbound_webhook.failed!
      rescue StandardError => e
        Rails.logger.error(
          "Failed to process webhook: #{e.message}, Webhook ID: #{inbound_webhook.id}",
        )
        inbound_webhook.failed!
      end
    end

    private

    def service(action)
      "Beckn::Api::On#{action.capitalize}DataService".constantize
    rescue NameError => e
      Rails.logger.error(e)
      nil
    end

    def handle_response(response, inbound_webhook)
      if response.is_a?(Net::HTTPSuccess)
        inbound_webhook.processed!
      else
        inbound_webhook.failed!
      end
    end
  end
end
