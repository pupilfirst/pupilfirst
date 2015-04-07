class RemoveUnusedColumnsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :pan, :string
    remove_column :users, :religion, :string
    remove_column :users, :father_id, :string
    remove_column :users, :mother_maiden_name, :string
    remove_column :users, :married, :boolean
    remove_column :users, :designation, :string
    remove_column :users, :educational_qualification, :text
    remove_column :users, :current_occupation, :string
  end
end
