class CreateSubmissionReports < ActiveRecord::Migration[6.1]
  def change
    create_table :submission_reports do |t|
      t.string :status
      t.string :conclusion
      t.datetime :started_at
      t.datetime :completed_at
      t.references :submission, foreign_key: { to_table: :timeline_events }
      t.text :test_report
      t.timestamps
    end
  end
end
