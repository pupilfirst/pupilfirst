module Startups
  # Returns fee applicable to a startup, taking into account applied coupon, and amounts already paid.
  class FeeAndCouponDataService
    # TODO: The base fee should probably be read from the startup entry.
    BASE_FEE = 100_000

    def initialize(startup)
      @startup = startup
    end

    def props
      {
        fee: fee_props,
        coupon: coupon_props
      }
    end

    private

    def fee_props
      # Undiscounted fee, for all founders in team.
      original_fee = @startup.billing_founders_count * BASE_FEE

      # Discounted fee, for all founders in team.
      discounted_fee = coupon.blank? ? original_fee : (original_fee * (coupon.discount_percentage / 100.0)).to_i

      paid_fee = @startup.payments.paid.sum(:amount).to_i

      # Remaining fee, payable for team.
      payable_fee = discounted_fee - paid_fee

      # Calculated EMI, as per discounted fee.
      calculated_emi = (discounted_fee / 6).round

      # Actual EMI is the lower of calculated EMI, or remaining payable amount. A small adjustment is made to the
      # remaining payable amount in the check, to ensure that even with rounding of previous payments, the last payment
      # occurs on the last month.
      emi = calculated_emi <= (payable_fee - 10) ? calculated_emi : payable_fee

      {
        originalFee: original_fee,
        discountedFee: discounted_fee,
        payableFee: payable_fee,
        emi: emi
      }
    end

    def coupon_props
      return if coupon.blank?

      {
        code: coupon.code,
        discount: coupon.discount_percentage,
        instructions: coupon.instructions
      }
    end

    def coupon
      @coupon ||= @startup.applied_coupon
    end
  end
end
