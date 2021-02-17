module Developers
  class EventPublisher
    def execute(course, event_type, actor, resource)
      ActiveSupport::Notifications.instrument("#{event_type}.pupilfirst", resource_id: resource.id, actor_id: actor.id, course_id: course.id)
    end
  end
end
