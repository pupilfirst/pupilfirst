class AddMilestoneToTargets < ActiveRecord::Migration[6.1]
  def change
    add_column :targets, :milestone, :boolean, default: false
    add_column :targets, :milestone_number, :integer
  end
end
