desc 'Notify inactive users in school and delete notified users'
task user_inactivity_notification_and_deletion: :environment do
  InactivityNotificationAndDeletionService.new.execute
end

