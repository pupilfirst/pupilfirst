module Payments
  class ProcessPaymentService
    def initialize(payment)
      @payment = payment
    end

    def execute
      return if @payment.paid_at.present?
      @payment.update!(paid_at: Time.zone.now, payment_type: inferred_payment_type)
    end

    private

    def inferred_payment_type
      @payment.startup.level.number.positive? ? Payment::TYPE_RENEWAL : Payment::TYPE_ADMISSION
    end
  end
end
