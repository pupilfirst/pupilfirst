class DropEngineeringMetrics < ActiveRecord::Migration[5.2]
  def up
    drop_table :engineering_metrics
  end

  def down
    create_table :engineering_metrics do |t|
      t.jsonb :metrics, default: {}, null: false
      t.datetime :week_start_at
    end
  end
end
