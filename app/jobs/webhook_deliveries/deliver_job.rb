module WebhookDeliveries
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform(event_type, course, resource)
      webhook_endpoint = course.webhook_endpoint
      payload = {
        data: data(event_type, resource),
        event: event_type
      }
      uri = URI.parse(webhook_endpoint.webhook_url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      response = http.request(request)

      WebhookDelivery.create!(
        event: event_type,
        payload: payload,
        course: course,
        webhook_url: webhook_endpoint.webhook_url,
        sent_at: Time.now,
        status: response.code,
        response_headers: response.header,
        response_body: response.body
      )
    end

    def data(event_type, resource)
      case event_type
        when WebhookDelivery.events[:submission_created]
          TimelineEvents::CreateWebhookDataService.new(resource).data
        else
          raise "undefined webhook event type: #{event_type}"
      end
    end
  end
end
