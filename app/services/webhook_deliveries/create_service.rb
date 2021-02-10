module WebhookDeliveries
  class CreateService
    def execute(course, event_type, resource)
      webhook_endpoint = course.webhook_endpoint

      return unless webhook_endpoint&.active?

      return unless event_type.in? webhook_endpoint.events

      WebhookDeliveries::DeliverJob.perform_later(event_type, course, resource)
    end
  end
end
