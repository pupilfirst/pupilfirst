class UpdateLatestForTimelineEvents < ActiveRecord::Migration[5.2]
  def up
    latest_event_ids = []
    # Handle founder events
    founder_targets = Target.founder
    events_for_founder_targets = TimelineEvent.where(target: founder_targets)
    events_for_founder_targets.each do |event|
      latest_event = TimelineEvent.where(target_id: event.target_id, founder_id: event.founder_id, startup_id: event.startup_id).order('created_at DESC').first
      latest_event_ids << latest_event.id
    end


    # Handle team events
    team_targets = Target.not_founder
    events_for_team_targets = TimelineEvent.where(target: team_targets)
    events_for_team_targets.each do |event|
      latest_event = TimelineEvent.where(target_id: event.target_id, startup_id: event.startup_id).order('created_at DESC').first
      latest_event_ids << latest_event.id
    end

    latest_event_ids = latest_event_ids.uniq

    TimelineEvent.where(id: latest_event_ids).update_all(latest: true)
  end

  def down
    TimelineEvent.update_all(latest: nil)
  end
end
