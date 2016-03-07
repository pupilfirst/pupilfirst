class AddTimelineTouredToFounder < ActiveRecord::Migration
  def change
    add_column :founders, :timeline_toured, :boolean
  end
end
