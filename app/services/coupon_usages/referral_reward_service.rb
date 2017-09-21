module CouponUsages
  class ReferralRewardService
    def initialize(coupon_usage)
      @coupon_usage = coupon_usage
      @coupon = @coupon_usage.coupon
      @referrer_startup = @coupon.referrer_startup
    end

    def execute
      return if @referrer_startup.blank?

      pending_payment.present? ? extend_reward_days : extend_current_subscription

      # Mark the coupon usage as rewarded.
      @coupon_usage.update!(rewarded_at: Time.zone.now)

      # Send an email notifying referrer of reward.
      StartupMailer.referral_reward(@referrer_startup, @coupon_usage.startup, @coupon, pending_payment.present?).deliver_later
    end

    private

    def pending_payment
      @pending_payment ||= Startups::PendingPaymentService.new(@referrer_startup).fetch
    end

    # Record the reward days on the startup entry, to be 'paid out' later when the startup renews their subscription.
    def extend_reward_days
      @referrer_startup.referral_reward_days += @coupon.referrer_extension_days
      @referrer_startup.save!
    end

    # Record the reward immediately, to the active subscription payment entry.
    def extend_current_subscription
      current_payment = @referrer_startup.payments.paid.order(:billing_start_at).last
      current_payment.update!(billing_end_at: current_payment.billing_end_at + @coupon.referrer_extension_days.days)
    end
  end
end
