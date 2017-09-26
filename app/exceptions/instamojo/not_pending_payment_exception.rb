class Instamojo
  # Raised when the DisablePaymentRequestService is called with a payment that isn't pending.
  class NotPendingPaymentException < StandardError
  end
end
