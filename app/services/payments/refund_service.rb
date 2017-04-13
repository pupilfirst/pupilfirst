module Payments
  # Refunds a payment.
  class RefundService
    def initialize(payment)
      @payment = payment
    end

    def execute
      if Rails.env.production?
        # Perform refund through Instamojo.
        Instamojo::RefundService.new.create(
          @payment.instamojo_payment_id,
          Instamojo::RefundService::TYPE_RFD,
          'Applicant has joined another team which has already paid the application fee.'
        )
      end

      # Mark payment as refunded.
      @payment.update!(refunded: true)
    end
  end
end
