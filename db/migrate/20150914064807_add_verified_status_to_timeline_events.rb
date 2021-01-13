class AddVerifiedStatusToTimelineEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :timeline_events, :verified_status, :string
  end
end
