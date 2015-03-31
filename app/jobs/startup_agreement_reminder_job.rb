class StartupAgreementReminderJob < ActiveJob::Base
  queue_as :default

  def perform
    # Reminders for expiry in 1 month, and 20 days.
    one_month_from_now = 30.days.from_now.beginning_of_day..30.days.from_now.end_of_day
    twenty_days_from_now = 20.days.from_now.beginning_of_day..20.days.from_now.end_of_day

    Startup.where(agreement_ends_at: [one_month_from_now, twenty_days_from_now]).each do |startup|
      expires_in = ((startup.agreement_ends_at - Time.zone.now) / 1.day).round
      renew_within = expires_in - 15

      # Push notification
      push_message = "Your incubation agreement expires in #{expires_in} days. To continue enjoying the services " +
        "provided by Startup Village, please renew your agreement within #{renew_within} days."

      startup.founders.each do |user|
        UserPushNotifyJob.perform_later(user.id, 'startup_agreement_expiry', push_message)
      end

      # Email
      StartupMailer.agreement_expiring_soon(startup, expires_in, renew_within).deliver_later

      # Log this event.
      Rails.llog.info event: :agreement_expiry_mail, startup_id: startup.id, expires_in: expires_in
    end
  end
end
