module Developers
  class NotificationService
    def initialize(
      webhook_service: WebhookDeliveries::CreateService.new,
      event_publisher: Developers::EventPublisher.new
    )
      @webhook_service = webhook_service
      @event_publisher = event_publisher
    end

    def execute(context, event_type, actor, resource)
      @event_publisher.execute(context, event_type, actor, resource)
      @webhook_service.execute(context, event_type, resource)
    end
  end
end
