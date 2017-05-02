class AddWeekStartAtToEngineeringMetric < ActiveRecord::Migration[5.0]
  def change
    add_column :engineering_metrics, :week_start_at, :datetime
  end
end
