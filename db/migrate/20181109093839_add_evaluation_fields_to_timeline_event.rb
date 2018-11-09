class AddEvaluationFieldsToTimelineEvent < ActiveRecord::Migration[5.2]
  def up
    add_column :timeline_events, :evaluator_id, :integer
    add_foreign_key :timeline_events, :faculty, column: :evaluator_id
    remove_column :timeline_events, :evaluated, :boolean
    add_column :timeline_events, :evaluated_at, :datetime
  end

  def down
    remove_column :timeline_events, :evaluated_at, :datetime
    add_column :timeline_events, :evaluated, :boolean, default: false
    remove_column :timeline_events, :evaluator_id
  end
end
