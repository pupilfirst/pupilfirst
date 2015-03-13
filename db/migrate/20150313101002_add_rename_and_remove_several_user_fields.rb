class AddRenameAndRemoveSeveralUserFields < ActiveRecord::Migration
  def change
    rename_column :users, :communication_address, :address
    add_column :users, :district, :string
    add_column :users, :state, :string
    add_column :users, :years_of_work_experience, :integer
    add_column :users, :year_of_graduation, :integer
    add_column :users, :college_id, :integer
    remove_column :users, :college, :string
  end
end
