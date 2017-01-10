class AddShareOnFacebookToTimelineEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :timeline_events, :share_on_facebook, :boolean, default: false
  end
end
