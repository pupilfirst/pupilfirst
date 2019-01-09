class RemoveSubmittabilityFromTargets < ActiveRecord::Migration[5.2]
  def change
    remove_column :targets, :submittability
  end
end
