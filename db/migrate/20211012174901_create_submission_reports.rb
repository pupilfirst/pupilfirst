class CreateSubmissionReports < ActiveRecord::Migration[6.1]
  def change
    create_table :submission_reports do |t|
      t.string :status
      t.references :submission, foreign_key: { to_table: :timeline_events }
      t.string :description
      t.timestamps
    end
  end
end
