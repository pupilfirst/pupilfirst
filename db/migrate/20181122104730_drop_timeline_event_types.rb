class DropTimelineEventTypes < ActiveRecord::Migration[5.2]
  def up
    drop_table :timeline_event_types
    remove_column :timeline_events, :timeline_event_type_id, :integer, index:true
    remove_column :targets, :timeline_event_type_id, :integer, index:true
  end

  def down
    create_table :timeline_event_types, id: :serial do |t|
      t.string :key
      t.string :title
      t.text :sample_text
      t.string :badge
      t.string :role, index: true
      t.string :proof_required
      t.string :suggested_stage
      t.boolean :major
      t.boolean :archived, default: false, null: false

      t.timestamps
    end

    add_reference :timeline_events, :timeline_event_type
    add_reference :targets, :timeline_event_type

  end
end
