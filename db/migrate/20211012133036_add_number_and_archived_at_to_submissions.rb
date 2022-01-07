class AddNumberAndArchivedAtToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :timeline_events, :number, :integer, null: false, default: 1
    add_column :timeline_events, :archived_at, :datetime
  end
end
