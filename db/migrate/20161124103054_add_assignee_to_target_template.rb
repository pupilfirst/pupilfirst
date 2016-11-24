class AddAssigneeToTargetTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :target_templates, :assignee_id, :integer
    add_index :target_templates, :assignee_id
    add_column :target_templates, :assignee_type, :string
    add_index :target_templates, :assignee_type
  end
end
