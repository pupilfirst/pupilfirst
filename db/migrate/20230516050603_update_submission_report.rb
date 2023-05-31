class UpdateSubmissionReport < ActiveRecord::Migration[6.1]
  class SubmissionReport < ApplicationRecord
  end
  def change
    add_column :submission_reports, :reporter, :citext, index: true
    add_column :submission_reports, :target_url, :string
    add_column :submission_reports, :heading, :string
    rename_column :submission_reports, :test_report, :report

    SubmissionReport.reset_column_information
    SubmissionReport.all.each do |report|
      report.update(
        status: report.conclusion.presence || report.status,
        reporter: "Virtual Teaching Assistant",
      )
    end

    change_column_default :submission_reports, :status, "queued"
    change_column_null :submission_reports, :reporter, false
    add_index :submission_reports, %i[submission_id reporter], unique: true
  end
end
