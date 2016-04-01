class AddSlackChannelToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :slack_channel, :string
  end
end
