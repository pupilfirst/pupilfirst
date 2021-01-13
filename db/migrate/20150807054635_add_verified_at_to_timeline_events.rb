class AddVerifiedAtToTimelineEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :verified_at, :datetime
  end
end
