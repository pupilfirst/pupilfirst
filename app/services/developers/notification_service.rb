module Developers
  class NotificationService
    def execute(course, event_type, _actor, resource)
      WebhookDeliveries::CreateService.new.execute(course, event_type, resource)
    end
  end
end
