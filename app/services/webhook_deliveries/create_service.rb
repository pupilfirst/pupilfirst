module WebhookDeliveries
  class CreateService
    def initialize(course, event_type)
      @course = course
      @event_type = event_type
    end

    def execute(resource)
      return unless webhook_endpoint&.active?

      return unless @event_type.in? webhook_endpoint.events

      WebhookDeliveries::DeliverJob.perform_later(@event_type, @course, resource)
    end

    private

    def webhook_endpoint
      @webhook_endpoint ||= @course.webhook_endpoint
    end
  end
end
