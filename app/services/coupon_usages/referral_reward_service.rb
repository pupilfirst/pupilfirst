module CouponUsages
  class ReferralRewardService
    def initialize(coupon_usage)
      @coupon_usage = coupon_usage
      @coupon = @coupon_usage.coupon
      @referrer_startup = @coupon.referrer_startup
    end

    def execute
      return if @referrer_startup.blank?

      pending_payment.present? ? extend_pending_subscription : extend_current_subscription

      # Mark the coupon applied as rewarded.
      @coupon_usage.update!(rewarded_at: Time.now)
    end

    private

    def pending_payment
      @pending_payment ||= @referrer_startup.payments.pending.order(:billing_start_at).last
    end

    def extend_pending_subscription
      pending_payment.update!(billing_end_at: pending_payment.billing_end_at + @coupon.referrer_extension_days.days)
    end

    def current_payment
      @current_payment ||= @referrer_startup.payments.paid.order(:billing_start_at).last
    end

    def extend_current_subscription
      current_payment.update!(billing_end_at: current_payment.billing_end_at + @coupon.referrer_extension_days.days)
    end
  end
end
