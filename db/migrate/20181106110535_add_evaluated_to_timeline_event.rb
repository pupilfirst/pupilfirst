class AddEvaluatedToTimelineEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :timeline_events, :evaluated, :boolean, default: false
  end
end
