module TimelineEvents
  class ReviewDataService
    def initialize(batch)
      @batch = batch
    end

    def data
      batch_timeline_events.pending.includes(:founder, :startup, :improvement_of, :target, :timeline_event_files).each_with_object([]) do |event, array|
        array << {
          event_id: event.id,
          founder_name: event.founder.name,
          startup_name: event.startup.product_name,
          event_on: event.event_on.strftime('%b %d, %Y'),
          created_at: event.created_at.strftime('%b %d %H:%M'),
          description: event.description
        }
      end
    end

    private

    def batch_timeline_events
      TimelineEvent.where(founder: @batch.founders)
    end
  end
end
