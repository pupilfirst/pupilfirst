class RemoveRevenueGenerateFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :revenue_generated, :integer
  end
end
