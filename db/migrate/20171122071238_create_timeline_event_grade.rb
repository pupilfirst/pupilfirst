class CreateTimelineEventGrade < ActiveRecord::Migration[5.1]
  def change
    create_table :timeline_event_grades do |t|
      t.references :timeline_event
      t.references :performance_criterion

      t.string :grade
      t.integer :karma_points
    end
  end
end
