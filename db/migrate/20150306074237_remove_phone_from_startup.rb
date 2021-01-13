class RemovePhoneFromStartup < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :phone, :string
  end
end
