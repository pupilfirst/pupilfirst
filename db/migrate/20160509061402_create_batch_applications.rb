class CreateBatchApplications < ActiveRecord::Migration
  def change
    create_table :batch_applications do |t|
      t.references :batch, index: true
      t.references :application_stage, index: true
      t.references :university, index: true
      t.string :product_name
      t.text :team_achievement

      t.timestamps null: false
    end
  end
end
