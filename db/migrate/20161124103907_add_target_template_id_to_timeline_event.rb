class AddTargetTemplateIdToTimelineEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :timeline_events, :target_template_id, :integer
  end
end
