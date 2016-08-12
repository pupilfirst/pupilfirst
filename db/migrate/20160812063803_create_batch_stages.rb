class CreateBatchStages < ActiveRecord::Migration
  def change
    create_table :batch_stages do |t|
      t.references :batch, index: true
      t.references :application_stage, index: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps null: false
    end
  end
end
