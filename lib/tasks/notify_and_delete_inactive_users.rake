desc 'Notify inactive users of impending deletion from school, and delete previously notified users'
task notify_and_delete_inactive_users: :environment do
  Users::InactivityNotificationAndDeletionService.new.execute
end

