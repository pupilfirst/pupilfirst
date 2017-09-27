module Startups
  class ValidateCouponUsageService
    def initialize(startup)
      @startup = startup
    end

    def invalid?
      coupon = @startup.applied_coupon
      return false if coupon.blank? || coupon.still_valid?
      @startup.coupon_usage.destroy!
      true
    end
  end
end
