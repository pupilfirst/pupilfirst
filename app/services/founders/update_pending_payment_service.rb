module Founders
  # Returns an updated payment with a Instamojo 'long_url' to which user can be redirected for completing payment.
  class UpdatePendingPaymentService
    include Loggable

    def initialize(founder)
      @founder = founder
    end

    # @return [Payment] Update payment entry, ready for the client to be redirected to (Instamojo)
    def update
      if payment.requested?
        # An attempt to pay was made at least once before.
        if payment.amount == fee_payable
          log "Payment ##{@payment.id} amount is unchanged. Returning payment after verifying validity at Instamojo..."

          Instamojo::VerifyPaymentRequestService.new(payment).verify
        else
          log "Payment ##{@payment.id} amount has changed from #{payment.amount.to_i} to #{fee_payable}. Rebuilding payment..."

          rebuild_payment_request
        end
      else
        log "Fresh Payment ##{@payment.id} encountered. Creating new payment request at Instamojo..."

        Instamojo::RequestPaymentService.new(payment).request
      end
    end

    private

    def payment
      @payment ||= Startups::PendingPaymentService.new(@founder.startup).fetch
    end

    def rebuild_payment_request
      # Disable the existing payment request at Instamojo.
      disabled_payment = Instamojo::DisablePaymentRequestService.new(payment).disable

      # And create another request.
      Instamojo::RequestPaymentService.new(disabled_payment).request
    end

    def fee_payable
      Startups::FeeAndCouponDataService.new(@founder.startup).emi
    end
  end
end
