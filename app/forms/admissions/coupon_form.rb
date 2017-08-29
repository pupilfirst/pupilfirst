module Admissions
  class CouponForm < Reform::Form
    attr_accessor :founder

    property :code, virtual: true, validates: { presence: true }

    validate :code_must_be_valid

    def code_must_be_valid
      errors[:code] << 'code is not valid' unless coupon.present? && coupon.still_valid?
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
  end
end
