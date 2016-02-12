class RenameUserIdsToFounderIds < ActiveRecord::Migration
  def change
    rename_column :karma_points, :user_id, :founder_id
    rename_column :public_slack_messages, :user_id, :founder_id
    rename_column :timeline_events, :user_id, :founder_id
  end
end
