module Payments
  # Creates a payment entry five days before the expiry of current subscription and sends an email with the payment link

  # Sends a reminder once again 3 days before expiry of subscription.
  class BillingService
    def execute
      return unless expiring_in_five_days.exists? || expiring_in_three_days.exists?

      expiring_in_five_days.each do |payment|
        create_payment(payment.founder, payment)
        email_team(payment)
      end

      expiring_in_three_days.each do |payment|
        pending_payment = Payment.pending.find_by(startup: payment.startup)
        pending_payment.present? && email_team(payment)
      end
    end

    private

    def expiring_in_five_days
      @expiring_in_five_days = Payment.paid.where(billing_end_at: 5.days.from_now.beginning_of_day..5.days.from_now.end_of_day)
    end

    def expiring_in_three_days
      @expiring_in_three_days = Payment.paid.where(billing_end_at: 3.days.from_now.beginning_of_day..3.days.from_now.end_of_day)
    end

    def create_payment(founder, last_payment)
      Payments::CreateService.new(founder, skip_instamojo: true, billing_start_at: last_payment.billing_end_at).create
    end

    def email_team(payment)
      StartupMailer.payment_reminder(payment).deliver_later
    end

    def payment_created(startup)
      Payment.where(startup: startup).order('created_at DESC').first
    end
  end
end
