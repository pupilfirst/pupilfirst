module TimelineEvents
  class ReviewDataService
    def initialize(batch)
      @batch = batch
    end

    def data
      batch_timeline_events.pending.includes(:founder, :startup, :improvement_of, :target, :timeline_event_files).map do |timeline_event|
      end
    end

    private

    def batch_timeline_events
      TimelineEvent.where(founder: @batch.founders)
    end
  end
end
