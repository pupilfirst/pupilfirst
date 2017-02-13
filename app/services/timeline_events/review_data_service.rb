module TimelineEvents
  class ReviewDataService
    def initialize(batch)
      @batch = batch
    end

    def data
      batch_timeline_events.pending.includes(:timeline_event_type, :founder, :startup, :target, :timeline_event_files).order('timeline_events.created_at').each_with_object({}) do |event, hash|
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
          files: event.timeline_event_files
        }
      end
    end

    private

    def batch_timeline_events
      TimelineEvent.where(founder: @batch.founders)
    end
  end
end
