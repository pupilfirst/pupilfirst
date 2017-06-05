module Admissions
  class CouponForm < Reform::Form
    attr_accessor :founder

    property :code, virtual: true, validates: { presence: true }

    validate :code_must_be_valid
    validate :coupon_must_be_applicable

    def code_must_be_valid
      errors[:code] << 'code is not valid' unless coupon.present? && coupon.still_valid?
    end

    def coupon_must_be_applicable
      return if coupon.blank?
      errors[:code] << applicability_service.error_message unless applicability_service.applicable?
    end

    def apply_coupon
      CouponUsage.create!(coupon: coupon, startup: founder.startup)
    end

    def prepopulate!(founder)
      self.founder = founder
    end

    private

    def coupon
      Coupon.find_by(code: code)
    end

    def applicability_service
      @applicability_service ||= Coupons::ApplicabilityService.new(coupon, founder)
    end
  end
end
