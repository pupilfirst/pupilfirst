class AddTimestampToPublicSlackMessages < ActiveRecord::Migration
  def change
    add_column :public_slack_messages, :timestamp, :string
  end
end
