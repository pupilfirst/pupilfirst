class AddEvaluatedAtForSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :timeline_events, :evaluated_at, :datetime
  end
end
