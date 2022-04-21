module WebhookDeliveries
  class CreateService
    def execute(course, event_key, actor, resource)
      event_value = WebhookDelivery.events[event_key]

      raise "Invalid event_type #{event_key} encountered" if event_value.blank?

      webhook_endpoint = course.webhook_endpoint

      return unless webhook_endpoint&.active?
      return unless event_value.in?(webhook_endpoint.events)

      WebhookDeliveries::DeliverJob.perform_later(
        event_value,
        course,
        actor,
        resource
      )
    end
  end
end
