class AddMilestoneToTargets < ActiveRecord::Migration[6.1]
  def change
    add_reference :targets, :milestone, foreign_key: true
  end
end
