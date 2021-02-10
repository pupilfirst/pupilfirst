module WebhookDeliveries
  class CreateService
    def execute(context, event_type, resource)
      webhook_endpoint = context.webhook_endpoint

      return unless webhook_endpoint&.active?

      return unless event_type.in? webhook_endpoint.events

      WebhookDeliveries::DeliverJob.perform_later(event_type, context, resource)
    end
  end
end
