module Coupons
  class CreateService
    USER_EXTENSION_DEFAULT = 15
    REFERRER_EXTENSION_DEFAULT = 10
    REDEEM_LIMIT_DEFAULT = 6

    def generate_referral(startup)
      Coupon.create!(
        code: unique_code,
        coupon_type: Coupon::TYPE_REFERRAL,
        user_extension_days: USER_EXTENSION_DEFAULT,
        referrer_extension_days: REFERRER_EXTENSION_DEFAULT,
        redeem_limit: REDEEM_LIMIT_DEFAULT,
        referrer_startup: startup
      )
    end

    def unique_code
      code = SecureRandom.random_number(36**6).to_s(36)
      Coupon.exists?(code: code) ? unique_code : code
    end
  end
end
