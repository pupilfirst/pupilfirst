module Founders
  class PostPaymentService
    def initialize(payment)
      @payment = payment
    end

    def execute
      raise 'PostPaymentService was called for an unpaid payment!' unless @payment.paid?

      Payment.transaction do
        # If payment was made outside active billing period, set start time to 'now'.
        @payment.billing_start_at = Time.zone.now if @payment.billing_start_at.blank? || @payment.billing_start_at.past?

        # Add payment period to billing start time to get billing end time.
        @payment.billing_end_at = @payment.billing_start_at + @payment.period.months

        # Add recorded referral reward, if any.
        if startup.referral_reward_days.positive?
          @payment.billing_end_at += startup.referral_reward_days.days

          # Wipe the reward days once it has been assigned to a payment.
          startup.referral_reward_days = 0
          startup.save!
        end

        @payment.save!
      end
    end

    private

    def startup
      @startup ||= @payment.startup
    end
  end
end
