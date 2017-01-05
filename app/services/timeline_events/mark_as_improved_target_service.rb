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
        @timeline_event.founder_or_startup.timeline_events
          .where(target_id: target.id, timeline_event_type: @timeline_event.timeline_event_type)
          .where.not(id: @timeline_event.id)
          .where('created_at < ?', @timeline_event.created_at)
          .order('created_at DESC')
          .first
      end
    end

    def target
      @target ||= @timeline_event.target
    end
  end
end
