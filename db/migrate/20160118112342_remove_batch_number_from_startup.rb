class RemoveBatchNumberFromStartup < ActiveRecord::Migration
  def change
    remove_column :startups, :batch_number, :integer
  end
end
