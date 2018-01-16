module Startups
  # Returns fee applicable to a startup, taking into account applied coupon, and amounts already paid.
  class FeeAndCouponDataService
    # TODO: The base fee should probably be read from the startup entry.
    BASE_FEE = 100_000

    def initialize(startup)
      @startup = startup
    end

    # Actual EMI is the lower of calculated EMI, or remaining payable amount. A small adjustment is made to the
    # remaining payable amount in the check, to ensure that even with rounding of previous payments, the last payment
    # occurs on the last month.
    def emi
      @emi ||= calculated_emi <= (payable_fee - 10) ? calculated_emi : payable_fee
    end

    # Data as props to be supplied to fee interface.
    def props
      {
        fee: {
          originalFee: original_fee,
          discountedFee: discounted_fee,
          payableFee: payable_fee,
          emi: emi
        },
        coupon: coupon_props
      }
    end

    private

    # Undiscounted fee, for all founders in team.
    def original_fee
      @startup.billing_founders_count * BASE_FEE
    end

    # Discounted fee, for all founders in team.
    def discounted_fee
      coupon.blank? ? original_fee : (original_fee * (coupon.discount_percentage / 100.0)).to_i
    end

    # Portion of fee already paid.
    def paid_fee
      @startup.payments.paid.sum(:amount).to_i
    end

    # Remaining fee, payable for team.
    def payable_fee
      discounted_fee - paid_fee
    end

    # Calculated EMI, as per discounted fee.
    def calculated_emi
      (discounted_fee / 6).round
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
