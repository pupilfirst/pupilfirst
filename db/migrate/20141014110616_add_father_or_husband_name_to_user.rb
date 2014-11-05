class AddFatherOrHusbandNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :father_or_husband_name, :string
  end
end
