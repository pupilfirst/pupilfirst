class RemoveKarmaPointsFromTimelineEventGrades < ActiveRecord::Migration[5.2]
  def change
    remove_column :timeline_event_grades, :karma_points
  end
end
