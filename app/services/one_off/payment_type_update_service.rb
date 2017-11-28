module OneOff
  # This one-off service iterates through all paid payments and sets their payment_type.
  class PaymentTypeUpdateService
    def execute
      Startup.joins(:payments).merge(Payment.paid).each do |startup|
        first_payment = startup.payments.paid.order(paid_at: :asc).first
        first_payment.update!(payment_type: Payment::TYPE_ADMISSION)
      end

      # rubocop:disable Rails/SkipsModelValidations
      Payment.paid.where(payment_type: nil).update_all(payment_type: Payment::TYPE_RENEWAL)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
