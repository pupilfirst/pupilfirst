class AddBatchIdToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :batch_id, :integer
    add_index :startups, :batch_id
  end
end
