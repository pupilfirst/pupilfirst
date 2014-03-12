class AddPanFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :pan, :string
    add_column :users, :din, :string
    add_column :users, :aadhar, :string
    add_reference :users, :other_name, index: true
    add_reference :users, :address, index: true
    add_reference :users, :father, index: true
    add_column :users, :mother_maiden_name, :string
    add_column :users, :married, :boolean
    add_column :users, :religion, :string
    add_reference :users, :guardian, index: true
  end
end
