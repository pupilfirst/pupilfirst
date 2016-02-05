class AddParentMessageIdToPublicSlackMessages < ActiveRecord::Migration
  def change
    add_column :public_slack_messages, :parent_message_id, :integer
  end
end
