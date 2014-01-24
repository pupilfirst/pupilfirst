class ChangePhone1ToPhoneInStartups < ActiveRecord::Migration
  def change
    rename_column :startups, :phone1, :phone
  end
end
