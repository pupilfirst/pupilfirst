class AddMissingIndexesAndFks < ActiveRecord::Migration[6.1]
  def change
    add_index :timeline_events, :evaluator_id
    add_index :timeline_events, :target_id
    add_foreign_key :timeline_events, :targets

    add_index :targets, :target_group_id
    add_foreign_key :markdown_attachments, :schools
    add_foreign_key :timeline_event_owners, :timeline_events

  end
end
