class AddAdminUserIdToApplicationSubmissionUrl < ActiveRecord::Migration[4.2]
  def change
    add_reference :application_submission_urls, :admin_user, index: true
  end
end
