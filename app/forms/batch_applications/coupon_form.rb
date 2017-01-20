module BatchApplications
  class CouponForm < Reform::Form
    property :code, virtual: true, validates: { presence: true }

    validate :code_must_be_valid

    def code_must_be_valid
      coupon = Coupon.find_by(code: code)
      errors[:code] << 'code not valid' unless coupon.present? && coupon.still_valid?
    end

    def apply_coupon!(batch_application)
      coupon = Coupon.find_by(code: code)
      batch_application.update!(coupon: coupon)
    end
  end
end
