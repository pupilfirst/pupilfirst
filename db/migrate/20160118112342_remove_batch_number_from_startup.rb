class RemoveBatchNumberFromStartup < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :batch_number, :integer
  end
end
