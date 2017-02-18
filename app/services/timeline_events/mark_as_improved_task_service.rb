module TimelineEvents
  class MarkAsImprovedTaskService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      return if task.blank?

      previous_event_for_task.update!(improved_timeline_event_id: @timeline_event.id) if previous_event_for_task.present?
    end

    private

    def previous_event_for_task
      @previous_event_for_task ||= begin
        @timeline_event.founder_or_startup.timeline_events
          .where(task: task, timeline_event_type: @timeline_event.timeline_event_type)
          .where.not(id: @timeline_event.id)
          .where('created_at < ?', @timeline_event.created_at)
          .order('created_at DESC')
          .first
      end
    end

    def task
      @task ||= @timeline_event.task
    end
  end
end
