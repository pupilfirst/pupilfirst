class RenameNameToFullname < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :name, :fullname
  end
end
