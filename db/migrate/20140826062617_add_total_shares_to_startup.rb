class AddTotalSharesToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :total_shares, :integer
  end
end
