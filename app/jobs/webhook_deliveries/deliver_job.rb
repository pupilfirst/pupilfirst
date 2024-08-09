module WebhookDeliveries
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform(event_type, course, actor, resource)
      webhook_endpoint = course.webhook_endpoint

      unless event_type.in?(webhook_endpoint.events)
        raise "#{event_type} was not one of the requested events in WebhookEndpoint##{webhook_endpoint.id}"
      end

      payload_data = data(event_type, actor, resource)

      return if payload_data.blank?

      payload = { data: payload_data, event: event_type }

      uri = URI.parse(webhook_endpoint.webhook_url)

      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      request['Authorization'] =
        "PF-HMAC-SHA256 #{hmac(webhook_endpoint.hmac_key, request.body)}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = Settings.webhook_read_timeout
      http.use_ssl = uri.scheme == 'https'

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
      WebhookDelivery.create!(
        error_class: e.class.name,
        event: event_type,
        payload: payload,
        course: course,
        webhook_url: webhook_endpoint.webhook_url,
        sent_at: Time.zone.now
      )
    end

    def data(event_type, actor, resource)
      case event_type
      when WebhookDelivery.events[:submission_created],
           WebhookDelivery.events[:submission_graded]
        TimelineEvents::CreateWebhookDataService.new(resource).data
      when WebhookDelivery.events[:course_completed]
        Courses::CompletionWebhookDataService.new(resource, actor).data
      else
        Rails.logger.error(
          "Could not find a data service for event #{event_type}"
        )

        nil
      end
    end

    def hmac(key, data)
      OpenSSL::HMAC.hexdigest('SHA256', key, data)
    end
  end
end
