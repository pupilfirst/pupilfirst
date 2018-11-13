class AddCompositeIndexToTimelineEventGrade < ActiveRecord::Migration[5.2]
  def change
    add_index :timeline_event_grades, [:timeline_event_id, :evaluation_criterion_id], unique: true, name: 'by_timeline_event_criterion'
  end
end
