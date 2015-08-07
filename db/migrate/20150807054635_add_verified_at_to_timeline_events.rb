class AddVerifiedAtToTimelineEvents < ActiveRecord::Migration
  def change
    add_column :timeline_events, :verified_at, :datetime
  end
end
