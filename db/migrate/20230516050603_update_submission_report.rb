class UpdateSubmissionReport < ActiveRecord::Migration[6.1]
  class SubmissionReport < ApplicationRecord
  end
  def change
    add_column :submission_reports, :context_name, :citext, null: false, default: 'Virtual Teaching Assistant', index: true
    add_column :submission_reports, :context_title, :string
    add_column :submission_reports, :target_url, :string

    SubmissionReport.reset_column_information
    SubmissionReport.all.each do |report|
      report.update(status: report.conclusion.presence || report.status)
    end
  end
end
