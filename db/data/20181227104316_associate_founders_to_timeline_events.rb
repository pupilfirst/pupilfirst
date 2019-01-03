class AssociateFoundersToTimelineEvents < ActiveRecord::Migration[5.2]
  def up
    founder_target_ids = Target.where(role: Target::ROLE_FOUNDER).pluck(:id)
    founder_events = TimelineEvent.where(target_id: founder_target_ids)
    founder_events.each do |event|
      TimelineEventOwner.create!(timeline_event: event, founder_id: event.founder_id)
    end

    startup_target_ids = Target.where.not(id: founder_target_ids)
    startup_events = TimelineEvent.where(target_id: startup_target_ids)
    startup_events.each do |event|
      Startup.find(event.startup_id).founders.each do |founder|
        TimelineEventOwner.create!(timeline_event: event, founder: event.founder)
      end
    end
  end

  def down
    TimelineEventOwner.delete_all
  end
end
