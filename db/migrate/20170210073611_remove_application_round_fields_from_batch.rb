class RemoveApplicationRoundFieldsFromBatch < ActiveRecord::Migration[5.0]
  def change
    remove_column :batches, :campaign_start_at, :datetime
    remove_column :batches, :target_application_count, :integer
  end
end
