module Webhooks
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform
      WebhookEntry.pending.each do |entry|
        uri = URI.parse(entry.webhook_url)
        request = Net::HTTP::Post.new(uri.request_uri)
        request['Content-Type'] = 'application/json'
        request.body = entry.payload
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        response = http.request(request)
        entry.update!(send_at: Time.now, status: response.code)
      end
    end
  end
end
