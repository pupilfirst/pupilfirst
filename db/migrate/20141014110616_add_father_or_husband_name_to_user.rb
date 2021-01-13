class AddFatherOrHusbandNameToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :father_or_husband_name, :string
  end
end
