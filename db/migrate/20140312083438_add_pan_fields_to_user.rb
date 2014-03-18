class AddPanFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :pan, :string
    add_column :users, :din, :string
    add_column :users, :aadhaar, :string
    add_reference :users, :other_name, index: true
    add_reference :users, :address, index: true
    add_reference :users, :father, index: true
    add_column :users, :is_director, :boolean, default: false
    add_column :users, :mother_maiden_name, :string
    add_column :users, :married, :boolean
    add_column :users, :current_occupation, :string
    add_column :users, :educational_qualification, :text
    add_column :users, :place_of_birth    , :string
    add_column :users, :religion, :string
    add_reference :users, :guardian, index: true
  end
end
