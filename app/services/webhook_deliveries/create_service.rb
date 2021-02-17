module WebhookDeliveries
  class CreateService
    def execute(course, event_type, resource)
      event_value = WebhookDelivery.events[event_type]

      raise "Invalid event_type #{event_type} encountered" if event_value.blank?

      webhook_endpoint = course.webhook_endpoint

      return unless webhook_endpoint&.active?

      WebhookDeliveries::DeliverJob.perform_later(event_value, course, resource)
    end
  end
end
