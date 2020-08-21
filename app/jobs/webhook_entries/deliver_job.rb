module WebhookEntries
  class DeliverService
    def perform(webhook_entry)
      uri = URI.parse(webhook_entry.webhook_url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = webhook_entry.payload
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      response = http.request(request)
      webhook_entry.update!(send_at: Time.now, status: response.code)
    end
  end
end
