module Admissions
  class CouponForm < Reform::Form
    attr_reader :current_founder

    property :code, virtual: true, validates: { presence: true }

    validate :code_must_be_valid

    def initialize(record, current_founder)
      @current_founder = current_founder
      super(record)
    end

    def code_must_be_valid
      errors[:code] << 'is not valid' unless coupon.present? && coupon.still_valid?
    end

    def apply_coupon
      CouponUsage.create!(coupon: coupon, startup: current_founder.startup)
    end

    private

    def coupon
      Coupon.find_by(code: code)
    end
  end
end
