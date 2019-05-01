class DropProductMetrics < ActiveRecord::Migration[5.2]
  def change
    drop_table :product_metrics
  end
end
