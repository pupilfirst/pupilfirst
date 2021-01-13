class AddFileToApplicationSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :application_submissions, :file, :string
  end
end
