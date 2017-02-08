module BatchApplications
  class CouponForm < Reform::Form
    property :code, virtual: true, validates: { presence: true }
    property :applicant_email, virtual: true

    validate :code_must_be_valid
    validate :applicant_must_be_msp, if: :msp_coupon_applied?

    def code_must_be_valid
      errors[:code] << 'code not valid' unless coupon.present? && coupon.still_valid?
    end

    def applicant_must_be_msp
      errors[:code] << 'code only valid for Microsoft Student Partners' unless applicant_has_msp_email?
    end

    def apply_coupon!(batch_application)
      CouponUsage.create!(coupon: coupon, batch_application: batch_application)
    end

    def prepopulate!(batch_application)
      self.applicant_email = batch_application&.team_lead&.email
    end

    private

    def coupon
      Coupon.find_by(code: code)
    end

    def msp_coupon_applied?
      return false unless coupon.present?

      coupon.coupon_type == Coupon::TYPE_MSP
    end

    def applicant_has_msp_email?
      (applicant_email =~ /@studentpartner.com\z/).present?
    end
  end
end
