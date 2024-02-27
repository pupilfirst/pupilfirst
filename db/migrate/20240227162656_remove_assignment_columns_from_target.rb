class RemoveAssignmentColumnsFromTarget < ActiveRecord::Migration[7.0]
  def change
    remove_column :targets, :role, :string
    remove_column :targets, :completion_instructions, :string
    remove_column :targets, :milestone, :boolean
    remove_column :targets, :milestone_number, :integer
  end
end
