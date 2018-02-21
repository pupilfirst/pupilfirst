class RemoveChoreFromTarget < ActiveRecord::Migration[5.1]
  def change
    remove_column :targets, :chore, :boolean, default: false
  end
end
