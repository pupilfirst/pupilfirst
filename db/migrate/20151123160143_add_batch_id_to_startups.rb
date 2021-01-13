class AddBatchIdToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :batch_id, :integer
    add_index :startups, :batch_id
  end
end
