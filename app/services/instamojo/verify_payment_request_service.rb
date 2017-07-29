class Instamojo
  class VerifyPaymentRequestService
    include Loggable

    # @param payment [Payment] Requested payment that needs to be verified.
    def initialize(payment)
      @payment = payment
    end

    # @return [Payment] Verified payment.
    def verify
      request_details = instamojo.payment_request_details(payment_request_id: @payment.instamojo_payment_request_id)

      # If the payment is still valid, return it without modifications.
      log "Payment ##{@payment.id} is still valid."
      return @payment if valid?(request_details[:payment_request_status])

      # If invalid, create another request.
      log "Payment ##{@payment.id} is still invalid (#{request_details[:payment_request_status]}) - creating another request."
      Instamojo::RequestPaymentService.new(@payment).request
    end

    private

    def valid?(payment_request_status)
      payment_request_status.in? [Instamojo::PAYMENT_REQUEST_STATUS_PENDING, Instamojo::PAYMENT_REQUEST_STATUS_SENT]
    end

    def instamojo
      @instamojo ||= Instamojo.new
    end
  end
end
