module WebhookDeliveries
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform(webhook_entry)
      uri = URI.parse(webhook_entry.webhook_url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = webhook_entry.payload.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      response = http.request(request)
      webhook_entry.update!(sent_at: Time.now, status: response.code, response_headers: response.header, response_body: response.body)
    end
  end
end
