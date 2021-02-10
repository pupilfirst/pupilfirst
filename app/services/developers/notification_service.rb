module Developers
  class NotificationService
    def initialize(course, event_type)
      @course     = course
      @event_type = event_type
    end

    def execute(_actor, resource)
      WebhookDeliveries::CreateService.new(@course, @event_type).execute(resource)
    end
  end
end
