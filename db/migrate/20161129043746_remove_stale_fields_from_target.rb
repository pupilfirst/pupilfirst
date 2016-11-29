class RemoveStaleFieldsFromTarget < ActiveRecord::Migration[5.0]
  def change
    remove_column :targets, :days_from_start
    remove_column :targets, :populate_on_start
  end
end
