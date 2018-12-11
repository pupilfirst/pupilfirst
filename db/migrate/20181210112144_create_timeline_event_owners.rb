class CreateTimelineEventOwners < ActiveRecord::Migration[5.2]
  def change
    create_table :timeline_event_owners do |t|
      t.references :timeline_event
      t.references :founder

      t.timestamps
    end
  end
end
