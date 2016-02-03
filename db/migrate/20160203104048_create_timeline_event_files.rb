class CreateTimelineEventFiles < ActiveRecord::Migration
  def change
    create_table :timeline_event_files do |t|
      t.references :timeline_event, index: true, foreign_key: true
      t.string :file
      t.boolean :private

      t.timestamps null: false
    end
  end
end
