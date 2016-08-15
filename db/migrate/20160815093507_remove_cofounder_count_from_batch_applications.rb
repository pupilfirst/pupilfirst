class RemoveCofounderCountFromBatchApplications < ActiveRecord::Migration
  def change
    remove_column :batch_applications, :cofounder_count, :integer
  end
end
