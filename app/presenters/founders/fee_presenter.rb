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
        startup: startup_props,
        states: State.order(name: :asc).as_json(only: %i[id name])
      }.merge(Startups::FeeAndCouponDataService.new(@startup).props)
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

    def startup_props
      {
        billingAddress: @startup.billing_address,
        billingStateId: @startup.billing_state&.id
      }
    end

    def fee_service
      @fee_service ||= Startups::FeePayableService.new(@startup)
    end
  end
end
