module Admissions
  class CouponForm < Reform::Form
    attr_accessor :founder

    property :code, virtual: true, validates: { presence: true }

    validate :code_must_be_valid
    validate :founder_must_be_msp, if: :msp_coupon_applied?

    def code_must_be_valid
      errors[:code] << 'code is not valid' unless coupon.present? && coupon.still_valid?
    end

    def founder_must_be_msp
      errors[:code] << 'code is only valid for Microsoft Student Partners' unless founder_has_msp_email?
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

    def msp_coupon_applied?
      return false if coupon.blank?
      coupon.coupon_type == Coupon::TYPE_MSP
    end

    def founder_has_msp_email?
      (founder.email =~ /@studentpartner.com\z/).present?
    end
  end
end
