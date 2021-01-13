class AddBatchToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :batch, :integer
    add_index :startups, :batch
  end
end
