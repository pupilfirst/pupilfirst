class AssociateFoundersToTimelineEvents < ActiveRecord::Migration[5.2]
  def up
    TimelineEvent.all.each do |event|
      founders = if event.founder_event?
        Founder.where(id: event.founder_id)
      else
        Founder.where(startup_id: event.startup_id)
      end

      event.update!(founders: founders)
    end
  end

  def down
    TimelineEventOwner.delete_all
  end
end
