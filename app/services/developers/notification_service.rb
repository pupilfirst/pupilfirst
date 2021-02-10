module Developers
  class NotificationService
    def execute(context, event_type, _actor, resource)
      WebhookDeliveries::CreateService.new.execute(context, event_type, resource)
    end
  end
end
