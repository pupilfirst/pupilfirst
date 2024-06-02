require 'net/http'
require 'json'

module InboundWebhooks
  class BecknJob < ApplicationJob
    queue_as :default

    def perform(inbound_webhook)
      inbound_webhook.processing!
      payload = JSON.parse(inbound_webhook.body)
      action = payload["context"]["action"]

      begin
        service_class = "Api::On#{action.capitalize}DataService".constantize
        data = service_class.new(payload).execute
        response = BecknRespondService.new(School.first, payload).execute("on_#{action}", data)
        handle_response(response, inbound_webhook)
      rescue NameError
        inbound_webhook.failed!
      end
    end

    private

    def handle_response(response, inbound_webhook)
      if response.is_a?(Net::HTTPSuccess)
        inbound_webhook.processed!
      else
        inbound_webhook.failed!
      end
    end
  end
end
