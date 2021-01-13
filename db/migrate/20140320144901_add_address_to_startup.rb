class AddAddressToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :address, :text
  end
end
