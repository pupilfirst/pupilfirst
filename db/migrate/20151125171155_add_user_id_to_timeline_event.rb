class AddUserIdToTimelineEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :user_id, :integer
    add_index :timeline_events, :user_id
  end
end
