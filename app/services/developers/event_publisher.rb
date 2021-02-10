module Developers
  class EventPublisher
    def execute(context, event_type, actor, resource)
      ActiveSupport::Notifications.instrument("#{event_type}.pupilfirst", resource_id: resource.id, actor_id: actor.id, context_id: context.id)
    end
  end
end
