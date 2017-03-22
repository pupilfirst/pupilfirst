namespace :intercom_cleanup do
  desc 'Remove inactive users from intercom and upload the contact information to sendinblue'
  task remove_inactive_users: :environment do
    Intercom::InactiveUserDeletionService.new.execute
  end
end
