class AddVerifiedStatusToTimelineEvents < ActiveRecord::Migration
  def change
    add_column :timeline_events, :verified_status, :string
  end
end
