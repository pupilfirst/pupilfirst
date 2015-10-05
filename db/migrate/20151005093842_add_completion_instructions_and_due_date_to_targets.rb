class AddCompletionInstructionsAndDueDateToTargets < ActiveRecord::Migration
  def change
    add_column :targets, :completion_instructions, :string
    add_column :targets, :due_date, :datetime
  end
end
