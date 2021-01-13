class CreateTimelineEventTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :timeline_event_types do |t|
      t.string :key
      t.string :title
      t.text :sample_text

      t.timestamps null: false
    end
  end
end
