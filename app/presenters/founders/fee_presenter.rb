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
        disabled: true,
        paymentRequested: !!@payment&.requested?,
        startup: startup_props,
        states: State.order(name: :asc).as_json(only: %i[id name])
      }.merge(Startups::FeeAndCouponDataService.new(@startup).props)
    end

    private

    def startup_props
      {
        billingAddress: @startup.billing_address,
        billingStateId: @startup.billing_state&.id
      }
    end
  end
end
