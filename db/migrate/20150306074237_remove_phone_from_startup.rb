class RemovePhoneFromStartup < ActiveRecord::Migration
  def change
    remove_column :startups, :phone, :string
  end
end
