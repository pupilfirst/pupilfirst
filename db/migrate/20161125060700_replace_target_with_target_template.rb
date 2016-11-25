class ReplaceTargetWithTargetTemplate < ActiveRecord::Migration[5.0]
  def change
    remove_column :timeline_events, :target_id
    drop_table :targets
    rename_table :target_templates, :targets
    rename_column :timeline_events, :target_template_id, :target_id
  end
end
