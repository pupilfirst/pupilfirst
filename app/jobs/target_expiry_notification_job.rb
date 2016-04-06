class TargetExpiryNotificationJob < ActiveJob::Base
  queue_as :default

  def perform
    # send mild reminder 5 days before expiry
    Target.pending.due_on(5.days.from_now).each do |target|
      AllTargetNotificationsJob.perform_later target, 'mild_reminder'
    end

    # send strong reminder 2 days before expiry
    Target.pending.due_on(2.days.from_now).each do |target|
      AllTargetNotificationsJob.perform_later target, 'strong_reminder'
    end
  end
end
