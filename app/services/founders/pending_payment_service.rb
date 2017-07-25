module Founders
  MoreThanOnePendingPaymentsException = Class.new(StandardError)

  class PendingPaymentService
    def initialize(founder)
      @founder = founder
    end

    # @return [Payment] Returns a pending payment.
    def fetch
      pending_payments = @founder.payments.pending

      if pending_payments.count > 1
        raise MoreThanOnePendingPaymentsException, "Founder ##{@founder.id} has more than one pending payments with IDs: #{pending_payments.join(', ')}"
      else
        pending_payments.first
      end
    end
  end
end
