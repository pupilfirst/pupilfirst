module Founders
  class ReferralRewardService
    def initialize(coupon)
      @coupon = coupon
      @referrer = coupon.referrer
      @startup = coupon.founder.startup
    end

    def execute
      return if @referrer.blank?

      pending_payment.present? ? extend_pending_subscription : extend_current_subscription
    end

    private

    def pending_payment
      @pending_payment ||= @startup.payments.pending.order(:billing_start_at).last
    end

    def extend_pending_subscription
      pending_payment.update!(billing_end_at: pending_payment.billing_end_at + @coupon.referrer_extension_days.days)
    end

    def current_payment
      @current_payment ||= @startup.payments.paid.order(:billing_start_at).last
    end

    def extend_current_subscription
      current_payment.update!(billing_end_at: current_payment.billing_end_at + @coupon.referrer_extension_days.days)
    end
  end
end
