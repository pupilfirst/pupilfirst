module Founders
  class FeePresenter < ApplicationPresenter
    def initialize(view_context, startup, payment)
      @startup = startup
      @payment = payment
      super(view_context)
    end

    def interface_props
      {
        debug: true,
        disabled: false,
        paymentRequested: !!@payment&.requested?,
        coupon: coupon_props,
        fee: fee_props
      }
    end

    def undiscounted_fee
      @undiscounted_fee ||= fee_service.undiscounted_fee(period: @period)
    end

    def fee_payable
      @fee_payable ||= fee_service.fee_payable(period: @period)
    end

    def discount_applicable?
      fee_payable != undiscounted_fee
    end

    def bulk_package_discount
      {
        3 => Startups::FeePayableService::DISCOUNT_PERCENTAGE_THREE_MONTHS,
        6 => Startups::FeePayableService::DISCOUNT_PERCENTAGE_SIX_MONTHS
      }[@period].floor
    end

    def coupon_discount
      @startup.coupon_usage&.coupon&.discount_percentage
    end

    def discount_amount
      undiscounted_fee - fee_payable
    end

    private

    def fee_props
      # TODO: Calculate these numbers.
      {
        # Full undiscounted fee, for all founders in team.
        fullUndiscounted: 300_000,
        # Full fee (owed), for all founders in team.
        full: 300_000,
        # Undiscounted EMI figure, for display.
        emiUndiscounted: 50_000,
        # Discounted, payable EMI now.
        emi: 50_000
      }
    end

    def coupon_props
      coupon = @startup.applied_coupon

      return if coupon.blank?

      {
        code: coupon.code,
        discount: coupon.discount_percentage,
        instructions: coupon.instructions
      }
    end

    def fee_service
      @fee_service ||= Startups::FeePayableService.new(@startup)
    end
  end
end
