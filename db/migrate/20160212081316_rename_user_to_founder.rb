class RenameUserToFounder < ActiveRecord::Migration
  def change
    rename_table :users, :founders
  end
end
