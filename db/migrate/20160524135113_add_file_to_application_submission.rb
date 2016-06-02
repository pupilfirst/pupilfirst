class AddFileToApplicationSubmission < ActiveRecord::Migration
  def change
    add_column :application_submissions, :file, :string
  end
end
