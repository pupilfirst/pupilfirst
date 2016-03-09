class AddPopulateOnStartToTargetTemplate < ActiveRecord::Migration
  def change
    add_column :target_templates, :populate_on_start, :boolean
    add_index :target_templates, :populate_on_start
  end
end
