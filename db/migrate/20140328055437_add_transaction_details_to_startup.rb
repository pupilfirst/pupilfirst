class AddTransactionDetailsToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :transaction_details, :string
  end
end
