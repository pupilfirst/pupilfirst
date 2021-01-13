class AddRegisteredAddressToStartup < ActiveRecord::Migration[4.2]
  def change
    add_reference :startups, :registered_address, index: true
  end
end
