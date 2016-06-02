class CreateApplicationStageScores < ActiveRecord::Migration
  def change
    create_table :application_stage_scores do |t|
      t.references :application_stage, index: true
      t.references :batch_application, index: true
      t.integer :score
      t.text :submission_urls

      t.timestamps null: false
    end
  end
end
