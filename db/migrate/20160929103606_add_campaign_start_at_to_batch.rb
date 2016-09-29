class AddCampaignStartAtToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :campaign_start_at, :datetime
  end
end
