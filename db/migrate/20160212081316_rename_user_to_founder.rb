class RenameUserToFounder < ActiveRecord::Migration[4.2]
  def change
    rename_table :users, :founders
  end
end
