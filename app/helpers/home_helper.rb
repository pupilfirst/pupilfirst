module HomeHelper
  def timeline_events_to_showcase(event_count)
    events = []
    startups_to_exclude = []
    startups_to_include = Startup.leaderboard_toppers_for_batch Batch.last, count: 3
    event_count.times do
      event = get_next_event(exclude: startups_to_exclude, include: startups_to_include)
      events << event if event
      # prevent multiple events from the same startup
      startups_to_exclude << event.startup_id if event
    end
    events
  end

  def get_next_event(exclude: [], include: [])
    TimelineEvent.showcase.order(verified_at: :desc).where(startup_id: include).where.not(startup_id: exclude).first
  end
end
