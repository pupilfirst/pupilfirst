class AddTimelineTouredToFounder < ActiveRecord::Migration[4.2]
  def change
    add_column :founders, :timeline_toured, :boolean
  end
end
