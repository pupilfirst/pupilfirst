module ActiveAdmin
  module TimelineEventHelper
    def grouped_targets_for_linking(timeline_event)
      targets = timeline_event.startup.batch.targets

      targets = if timeline_event.timeline_event_type.founder_event?
        targets.founder
      else
        targets.not_founder
      end

      targets
    end
  end
end
