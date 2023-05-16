class AddMilestoneToTargets < ActiveRecord::Migration[6.1]
  def change
    add_column :targets, :milestone, :boolean, default: false
  end
end
