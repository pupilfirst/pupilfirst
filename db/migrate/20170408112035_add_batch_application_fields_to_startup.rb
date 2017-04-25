class AddBatchApplicationFieldsToStartup < ActiveRecord::Migration[5.0]
  def change
    add_column :startups, :courier_name, :string
    add_column :startups, :courier_number, :string
    add_column :startups, :partnership_deed, :string
    add_column :startups, :payment_reference, :string
  end
end
