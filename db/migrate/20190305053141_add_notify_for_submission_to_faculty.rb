class AddNotifyForSubmissionToFaculty < ActiveRecord::Migration[5.2]
  def change
    add_column :faculty, :notify_for_submission, :boolean, default: false
  end
end
