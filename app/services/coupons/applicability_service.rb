module Coupons
  class ApplicabilityService
    def initialize(coupon, founder)
      @coupon = coupon
      @founder = founder
    end

    def applicable?
      @applicable ||= case @coupon.coupon_type
        when Coupon::TYPE_REFERRAL then true
        when Coupon::TYPE_MSP then founder_has_msp_email?
      end
    end

    def error_message
      return nil if applicable?
      case @coupon.coupon_type
        when Coupon::TYPE_MSP then 'this code is only valid for Microsoft Student Partners'
      end
    end

    private

    def founder_has_msp_email?
      (@founder.email =~ /@studentpartner.com\z/).present?
    end
  end
end
