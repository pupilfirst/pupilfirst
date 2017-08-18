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

      # Award the startup the applicable extension.
      @payment.update!(billing_end_at: @payment.billing_end_at + @coupon.user_extension_days.days)

      # initiate referral refund
      CouponUsages::ReferralRewardService.new(@coupon_usage).execute
    end
  end
end
