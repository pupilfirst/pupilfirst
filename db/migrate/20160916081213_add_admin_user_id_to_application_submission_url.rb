class AddAdminUserIdToApplicationSubmissionUrl < ActiveRecord::Migration
  def change
    add_reference :application_submission_urls, :admin_user, index: true
  end
end
