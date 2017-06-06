module Coupons
  class ApplicabilityService
    def initialize(coupon, founder)
      @coupon = coupon
      @founder = founder
    end

    def applicable?
      @applicable ||= case @coupon.coupon_type
        when Coupon::TYPE_DISCOUNT then true
        when Coupon::TYPE_MSP then founder_has_msp_email?
        when Coupon::TYPE_MOOC_MERIT then founder_has_mooc_merit?
      end
    end

    def error_message
      return nil if applicable?
      case @coupon.coupon_type
        when Coupon::TYPE_MSP then 'this code is only valid for Microsoft Student Partners'
        when Coupon::TYPE_MOOC_MERIT then 'this code is only valid for students who scored above 30% in our MOOC'
      end
    end

    private

    def founder_has_msp_email?
      (@founder.email =~ /@studentpartner.com\z/).present?
    end

    def founder_has_mooc_merit?
      mooc_score = @founder.user&.mooc_student&.score
      mooc_score && mooc_score > 30
    end
  end
end
