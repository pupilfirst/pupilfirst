class AddReactionToIdToPublicSlackMessages < ActiveRecord::Migration
  def change
    add_column :public_slack_messages, :reaction_to_id, :integer
  end
end
