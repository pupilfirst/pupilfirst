class RemoveRevenueGenerateFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :revenue_generated, :integer
  end
end
