module HomeHelper
  def timeline_events_to_showcase(no_of_events)
    events = []
    startup_ids = []
    no_of_events.times do
      event = get_next_event(startup_ids)
      events << event if event
      startup_ids << event.startup_id if event
    end
    events
  end

  def get_next_event(startup_ids)
    TimelineEvent.showcase.order(verified_at: :desc).where.not(startup_id: startup_ids).first
  end
end
