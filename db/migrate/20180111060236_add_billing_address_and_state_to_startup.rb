class AddBillingAddressAndStateToStartup < ActiveRecord::Migration[5.1]
  def change
    add_column :startups, :billing_address, :text
    add_reference :startups, :billing_state, foreign_key: { to_table: :states }
  end
end
