class RenameFullnameToFirstname < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :fullname, :first_name
  end
end
