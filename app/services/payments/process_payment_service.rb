module Payments
  class ProcessPaymentService
    def initialize(payment)
      @payment = payment
    end

    def execute
      return if @payment.paid_at.present?
      @payment.update!(paid_at: Time.zone.now, payment_type: Payment::TYPE_NORMAL)
    end
  end
end
