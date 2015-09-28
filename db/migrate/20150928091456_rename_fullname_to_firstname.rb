class RenameFullnameToFirstname < ActiveRecord::Migration
  def change
    rename_column :users, :fullname, :first_name
  end
end
