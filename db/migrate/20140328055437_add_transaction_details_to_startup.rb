class AddTransactionDetailsToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :transaction_details, :string
  end
end
