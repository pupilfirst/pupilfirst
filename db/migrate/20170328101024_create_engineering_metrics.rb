class CreateEngineeringMetrics< ActiveRecord::Migration[5.0]
  def change
    create_table :engineering_metrics do |t|
      t.integer :week_start
      t.json :metrics, null: false, default: {}
    end

    add_index :engineering_metrics, :week_start
  end
end
