class TargetExpiryNotificationJob < ActiveJob::Base
  queue_as :default

  def perform
    # send mild reminder 5 days before expiry
    Target.pending.due_on(5.days.from_now).each(&:send_mild_reminder_on_slack)

    # send strong reminder 2 days before expiry
    Target.pending.due_on(2.days.from_now).each(&:send_strong_reminder_on_slack)
  end
end
