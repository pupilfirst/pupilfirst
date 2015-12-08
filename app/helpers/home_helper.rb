module HomeHelper
  def timeline_events_to_showcase(event_count)
    leading_startup_ids = Startup.leaderboard_toppers_for_batch Batch.current, count: event_count
    leading_startup_ids.map { |startup_id| Startup.find(startup_id).showcase_timeline_event }.compact
  end
end
