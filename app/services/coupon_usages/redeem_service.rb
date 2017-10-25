module CouponUsages
  class RedeemService
    def initialize(coupon_usage, payment)
      @coupon_usage = coupon_usage
      @coupon = coupon_usage.coupon
      @payment = payment
    end

    def execute
      # Mark the coupon applied as redeemed.
      @coupon_usage.update!(redeemed_at: Time.now)

      # Award the startup the applicable extension, if any.
      award_user_extension if @coupon.user_extension_days.present?

      # Award referrer extension, if any.
      award_referrer_extension if @coupon.referrer_extension_days.present?
    end

    private

    def award_user_extension
      @payment.update!(billing_end_at: @payment.billing_end_at + @coupon.user_extension_days.days)
    end

    def award_referrer_extension
      CouponUsages::ReferralRewardService.new(@coupon_usage).execute
    end
  end
end
