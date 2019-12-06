class RemoveExitedFlagFromFounders < ActiveRecord::Migration[6.0]
  def change
    remove_column :founders, :exited
  end
end
