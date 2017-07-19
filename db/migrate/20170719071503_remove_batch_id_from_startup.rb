class RemoveBatchIdFromStartup < ActiveRecord::Migration[5.1]
  def change
    remove_column :startups, :batch_id, :integer
  end
end
