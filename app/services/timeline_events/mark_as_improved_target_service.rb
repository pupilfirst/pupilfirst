module TimelineEvents
  class MarkAsImprovedTargetService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      return if target.blank?

      previous_event_for_target.update!(improved_timeline_event_id: @timeline_event.id) if previous_event_for_target.present?
    end

    private

    def previous_event_for_target
      @previous_event_for_target ||= begin
        TimelineEvent.joins(:founders).where(founders: { id: @timeline_event.founders.pluck(:id) }).where(target: @timeline_event.target, latest: false)
          .where('timeline_events.created_at < ?', @timeline_event.created_at)
          .order('timeline_events.created_at DESC')
          .first
      end
    end

    def target
      @target ||= @timeline_event.target
    end
  end
end
