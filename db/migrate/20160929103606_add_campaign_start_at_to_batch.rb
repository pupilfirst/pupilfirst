class AddCampaignStartAtToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :campaign_start_at, :datetime
  end
end
