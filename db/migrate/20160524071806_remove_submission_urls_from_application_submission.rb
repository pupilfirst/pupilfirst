class RemoveSubmissionUrlsFromApplicationSubmission < ActiveRecord::Migration[4.2]
  def change
    remove_column :application_submissions, :submission_urls, :text
  end
end
