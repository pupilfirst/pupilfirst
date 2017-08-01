module OneOff
  # rubocop:disable all
  class AddBillingDatesToPaymentsService
    # This is the date after which ongoing subscription was activated. A large number of startups were created after
    # this point. Startups created before this time should be given 5 years of subscription.
    DIVIDING_LINE_TIME = -'May 8, 2017 00:00:00 +0530'

    # These founders paid in a small gap during the opening of ongoing subscriptions, and switch to monthly billing.
    # These startups should be given 2 months subscription.
    FOUNDERS_WITH_EXTENSION = %w[apsr.pr@gmail.com gokul.a.s1996@gmail.com ashutosh.deshpande@studentpartner.com].freeze

    def initialize
      @report = []
    end

    def execute_and_report
      update_billing_dates(1.month, regular_startups)
      update_billing_dates(2.months.from_now, extension_startups, create_payment_if_missing: true)
      update_billing_dates(5.years, old_startups, create_payment_if_missing: true)

      @report
    end

    private

    def dividing_line_time
      Time.parse(DIVIDING_LINE_TIME)
    end

    def old_startups
      Startup.where('created_at < ?', dividing_line_time)
    end

    def extension_startups
      FOUNDERS_WITH_EXTENSION.map { |email| Founder.with_email(email).startup }
    end

    def regular_startups
      Startup.where('startups.created_at >= ?', dividing_line_time).joins(:payments).merge(Payment.paid).distinct
    end

    def update_billing_dates(duration_or_time, startups, create_payment_if_missing: false)
      startups.each do |startup|
        payment = if startup.payments.any?
          startup.payments.first
        else
          raise "Startup ##{startup.id} does not have a payment, and the create payment flag is turned off." unless create_payment_if_missing

          # Create a payment.
          payment = Payment.create!(
            startup: startup,
            founder: startup.admin || startup.founders.first,
            billing_start_at: Time.zone.now,
            billing_end_at: calculated_end(startup.created_at, duration_or_time),
            paid_at: Time.zone.now,
            notes: 'Payment automatically created by OneOff::AddBillingDatesToPaymentsService'
          )

          @report << add_to_report(startup, payment)

          payment
        end

        if payment.billing_end_at.blank? || payment.billing_end_at.past?
          raise "Found a Payment ##{payment.id} that wasn't paid" unless payment.paid?
          payment.billing_start_at = payment.paid_at
          payment.billing_end_at = calculated_end(payment.paid_at, duration_or_time)
          payment.save!

          @report << add_to_report(startup, payment)
        end
      end
    end

    def add_to_report(startup, payment)
      {
        startup_id: startup.id,
        product_name: startup.product_name,
        paid_at: payment.paid_at,
        billing_start_at: payment.billing_start_at,
        billing_end_at: payment.billing_end_at
      }
    end

    def calculated_end(start_time, duration_or_datetime)
      return (start_time + duration_or_datetime) if duration_or_datetime.is_a?(ActiveSupport::Duration)
      duration_or_datetime
    end
  end
  # rubocop:enable all
end
