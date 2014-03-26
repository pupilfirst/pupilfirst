class AddRegisteredAddressToStartup < ActiveRecord::Migration
  def change
    add_reference :startups, :registered_address, index: true
  end
end
