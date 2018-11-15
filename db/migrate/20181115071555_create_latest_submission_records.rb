class CreateLatestSubmissionRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :latest_submission_records do |t|
      t.references :founder, foreign_key: true
      t.references :target, foreign_key: true
      t.references :timeline_event, foreign_key: true

      t.timestamps
    end

    add_index :latest_submission_records, [:founder_id, :target_id], unique: true
  end
end
