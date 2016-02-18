class RemoveStaleFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :din, :string
    remove_column :users, :aadhaar, :string
    remove_column :users, :place_of_birth, :string
    remove_column :users, :salutation, :string
    remove_column :users, :company, :string
    remove_column :users, :father_or_husband_name, :string
    remove_column :users, :pin, :string
    remove_column :users, :district, :string
    remove_column :users, :state, :string
    remove_column :users, :years_of_work_experience, :string
    remove_column :users, :college_id, :integer
  end
end
