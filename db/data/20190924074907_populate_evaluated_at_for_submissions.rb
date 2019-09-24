class PopulateEvaluatedAtForSubmissions < ActiveRecord::Migration[5.2]
  def up
    TimelineEvent.where.not(evaluator_id: nil).each do |timeline_event|
      timeline_event.update!(evaluated_at: timeline_event.updated_at) if timeline_event.evaluated_at.nil?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
