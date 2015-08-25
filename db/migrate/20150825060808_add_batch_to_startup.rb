class AddBatchToStartup < ActiveRecord::Migration
  def change
    add_column :startups, :batch, :integer
    add_index :startups, :batch
  end
end
