class RemoveKeyFromTargets < ActiveRecord::Migration[5.2]
  def change
    remove_column :targets, :key
  end
end
