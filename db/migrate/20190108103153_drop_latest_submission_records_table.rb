class DropLatestSubmissionRecordsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :latest_submission_records
  end
end
