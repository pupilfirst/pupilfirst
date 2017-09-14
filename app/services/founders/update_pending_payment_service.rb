module Founders
  # Returns an updated payment with a Instamojo 'long_url' to which user can be redirected for completing payment.
  class UpdatePendingPaymentService
    include Loggable

    def initialize(founder, period)
      @founder = founder
      @period = period
    end

    # @return [Payment] Update payment entry, ready for the client to be redirected to (Instamojo)
    def update
      if payment.requested?
        # An attempt to pay was made at least once before.
        if @period == payment.period
          log "Payment ##{@payment.id} period is unchanged. Returning payment after verifying validity at Instamojo..."

          Instamojo::VerifyPaymentRequestService.new(payment, @period).verify
        else
          log "Payment ##{@payment.id} period has changed from #{payment.period} to #{@period}. Rebuilding payment..."

          rebuild_payment_request
        end
      else
        log "Fresh Payment ##{@payment.id} encountered. Creating new payment request at Instamojo..."

        Instamojo::RequestPaymentService.new(payment, @period).request
      end
    end

    private

    def payment
      @payment ||= Founders::PendingPaymentService.new(@founder).fetch
    end

    def rebuild_payment_request
      # Disable the existing payment request at Instamojo.
      disabled_payment = Instamojo::DisablePaymentRequestService.new(payment).disable

      # And create another request.
      Instamojo::RequestPaymentService.new(disabled_payment, @period).request
    end
  end
end
