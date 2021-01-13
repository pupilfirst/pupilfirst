class RemoveCofounderCountFromBatchApplications < ActiveRecord::Migration[4.2]
  def change
    remove_column :batch_applications, :cofounder_count, :integer
  end
end
