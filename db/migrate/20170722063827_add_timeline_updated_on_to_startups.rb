class AddTimelineUpdatedOnToStartups < ActiveRecord::Migration[5.1]
  def change
    add_column :startups, :timeline_updated_on, :date
  end
end
