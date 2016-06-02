class RemoveSubmissionUrlsFromApplicationSubmission < ActiveRecord::Migration
  def change
    remove_column :application_submissions, :submission_urls, :text
  end
end
