class Instamojo
  # Disables a payment request that was registered with Instamojo.
  class DisablePaymentRequestService < BaseService
    include Loggable

    def initialize(payment)
      @payment = payment
    end

    def disable
      # This service can only disable pending payment requests.
      raise Instamojo::NotPendingPaymentException unless @payment.requested?

      # Call the API route.
      post("payment-requests/#{@payment.instamojo_payment_request_id}/disable")

      log "Instamojo payment request for Payment ##{@payment.id} has been disabled. Nil-ing all related columns..."

      # Remove all fields related to payment request.
      @payment.period = nil
      @payment.amount = nil
      @payment.instamojo_payment_request_id = nil
      @payment.instamojo_payment_request_status = nil
      @payment.short_url = nil
      @payment.long_url = nil
      @payment.save!

      @payment
    end
  end
end
