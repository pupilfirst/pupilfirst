module Coupons
  class CreateService
    USER_EXTENSION_DEFAULT = 15
    REFERRER_EXTENSION_DEFAULT = 10
    REDEEM_LIMIT_DEFAULT = 0

    def generate_referral(startup)
      Coupon.create!(
        code: rand(36**6).to_s(36),
        coupon_type: Coupon::TYPE_REFERRAL,
        user_extension_days: USER_EXTENSION_DEFAULT,
        referrer_extension_days: REFERRER_EXTENSION_DEFAULT,
        redeem_limit: REDEEM_LIMIT_DEFAULT,
        referrer_startup: startup
      )
    end
  end
end
