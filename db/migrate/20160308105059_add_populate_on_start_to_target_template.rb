class AddPopulateOnStartToTargetTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :target_templates, :populate_on_start, :boolean
    add_index :target_templates, :populate_on_start
  end
end
