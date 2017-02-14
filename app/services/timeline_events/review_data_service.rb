module TimelineEvents
  class ReviewDataService
    include RoutesResolvable

    def initialize(batch)
      @batch = batch
    end

    def data
      batch_timeline_events.pending.includes(:timeline_event_type, :founder, :startup, :target, :timeline_event_files, improvement_of: :timeline_event_type).order('timeline_events.created_at').each_with_object({}) do |event, hash|
        hash[event.id] = {
          event_id: event.id,
          title: event.title,
          founder_id: event.founder_id,
          founder_name: event.founder.name,
          startup_id: event.startup_id,
          startup_name: event.startup.product_name,
          event_on: event.event_on.strftime('%b %d, %Y'),
          created_at: event.created_at.strftime('%b %d %H:%M'),
          description: event.description,
          target_id: event.target_id,
          target_title: event.target&.title,
          links: event.links,
          files: event.timeline_event_files,
          feedback_url: feedback_url(event),
          improvement_of: event.improvement_of,
          improvement_of_title: event.improvement_of&.title
        }
      end
    end

    private

    def batch_timeline_events
      TimelineEvent.where(founder: @batch.founders)
    end

    def feedback_url(timeline_event)
      url_helpers.new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          reference_url: url_helpers.startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}"),
          event_id: timeline_event.id
        }
      )
    end
  end
end
