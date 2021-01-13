class AddSlackChannelToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :slack_channel, :string
  end
end
