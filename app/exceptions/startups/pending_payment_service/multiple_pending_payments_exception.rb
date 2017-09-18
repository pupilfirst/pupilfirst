module Startups
  class PendingPaymentService
    # Raised when PendingPaymentService discovers that a startup has more than one pending payment, which shouldn't be possible.
    class MultiplePendingPaymentsException < StandardError
    end
  end
end
