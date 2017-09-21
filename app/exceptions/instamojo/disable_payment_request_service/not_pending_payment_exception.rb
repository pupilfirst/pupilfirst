class Instamojo
  class DisablePaymentRequestService
    # Raised when the DisablePaymentRequestService is called with a payment that isn't pending.
    class NotPendingPaymentException < StandardError
    end
  end
end
