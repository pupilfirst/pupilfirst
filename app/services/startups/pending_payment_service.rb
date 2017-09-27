module Startups
  class PendingPaymentService
    def initialize(startup)
      @startup = startup
    end

    # @return [Payment] Returns a pending payment.
    def fetch
      pending_payments = @startup.payments.pending

      if pending_payments.count > 1
        raise Startups::PendingPaymentService::MultiplePendingPaymentsException, "Startup ##{@startup.id} has more than one pending payments with IDs: #{pending_payments.join(', ')}"
      else
        pending_payments.first
      end
    end
  end
end
