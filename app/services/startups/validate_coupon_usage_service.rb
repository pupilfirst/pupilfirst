module Startups
  class ValidateCouponUsageService
    def initialize(startup)
      @startup = startup
    end

    def invalid?
      coupon = @startup.applied_coupon
      return false if coupon.blank? || coupon.still_valid?

      remove_latest_coupon
      true
    end

    private

    def remove_latest_coupon
      @startup.coupon_usage.destroy!
    end
  end
end
