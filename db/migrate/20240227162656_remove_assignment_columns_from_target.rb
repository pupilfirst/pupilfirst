class RemoveAssignmentColumnsFromTarget < ActiveRecord::Migration[7.0]
  def change
    remove_column :targets, :role, :string
    remove_column :targets, :completion_instructions, :string
    remove_column :targets, :milestone, :boolean, default: false
    remove_column :targets, :milestone_number, :integer
    remove_column :targets, :checklist, :jsonb, default: []
  end
end
