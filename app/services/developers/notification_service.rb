module Developers
  class NotificationService
    def initialize(webhook_service: WebhookDeliveries::CreateService.new)
      @webhook_service = webhook_service
    end

    def execute(context, event_type, _actor, resource)
      @webhook_service.execute(context, event_type, resource)
    end
  end
end
