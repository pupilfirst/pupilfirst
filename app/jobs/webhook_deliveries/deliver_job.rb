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
      request['Authorization'] = "PF-HMAC-SHA256 #{hmac(webhook_endpoint.hmac_key, request.body)}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = Rails.application.secrets.webhook_read_timeout
      http.use_ssl = (uri.scheme == 'https' && !Rails.env.development?)

      response = http.request(request)

      WebhookDelivery.create!(
        event: event_type,
        payload: payload,
        course: course,
        webhook_url: webhook_endpoint.webhook_url,
        sent_at: Time.zone.now,
        status: response.code,
        response_headers: response.header,
        response_body: response.body
      )

    rescue Net::OpenTimeout => e
      if event_type.in? course.webhook_endpoint.events
        WebhookDelivery.create!(
          error_class: e.class.name,
          event: event_type,
          payload: payload,
          course: course,
          webhook_url: webhook_endpoint.webhook_url,
          sent_at: Time.zone.now,
        )
      end
    end

    def data(event_type, resource)
      case event_type
        when WebhookDelivery.events[:submission_created]
          TimelineEvents::CreateWebhookDataService.new(resource).data
        else
          raise "Unknown webhook event type: #{event_type}"
      end
    end

    def hmac(key, data)
      OpenSSL::HMAC.hexdigest('SHA256', key, data)
    end
  end
end
