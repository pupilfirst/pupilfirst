module Founders
  class FeeOfferPresenter < ApplicationPresenter
    def initialize(view_context, startup, period)
      @startup = startup
      @period = period
      super(view_context)
    end

    def period_string
      view.pluralize(@period, 'month')
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

    def fee_service
      @fee_service ||= Startups::FeePayableService.new(@startup)
    end
  end
end
