class AddTotalSharesToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :total_shares, :integer
  end
end
