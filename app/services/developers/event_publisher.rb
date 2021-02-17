module Developers
  class EventPublisher
    def execute(event_type, actor, resource)
      ActiveSupport::Notifications.instrument("#{event_type}.pupilfirst", resource_id: resource.id, actor_id: actor.id)
    end
  end
end
