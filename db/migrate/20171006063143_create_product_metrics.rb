class CreateProductMetrics < ActiveRecord::Migration[5.1]
  def change
    create_table :product_metrics do |t|
      t.string :category
      t.integer :value
      t.integer :delta_period
      t.integer :delta_value
      t.string :assignment_mode
      t.references :faculty

      t.timestamps
    end
  end
end
