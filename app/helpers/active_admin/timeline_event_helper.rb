module ActiveAdmin
  module TimelineEventHelper
    def grouped_targets_for_linking(timeline_event)
      targets = if timeline_event.timeline_event_type.founder_event?
        # Return incomplete founder targets
        timeline_event.founder.targets
      else
        # Return incomplete non-founder targets
        timeline_event.startup.targets
      end

      pending = targets.pending.order('created_at DESC').pluck(:title, :id)
      expired = targets.expired.order('created_at DESC').pluck(:title, :id)
      completed = targets.where(status: Target::STATUS_DONE).order('created_at DESC').pluck(:title, :id)

      { Live: pending, Expired: expired, Completed: completed }
    end
  end
end
