module Payments
  # Creates a payment entry after contacting Instamojo API.
  #
  # Specifics of how this works can be controlled using options.
  class CreateService
    def initialize(founder, skip_instamojo: false, skip_payment: false)
      @founder = founder
      @startup = founder.startup
      @skip_instamojo = skip_instamojo
      @skip_payment = skip_payment
    end

    def execute
      payment = Payment.new(
        startup: @startup,
        founder: @founder
      )

      payment.amount = @startup.fee unless @skip_payment

      unless @skip_payment || @skip_instamojo
        payment = Instamojo::RequestPaymentService.new(payment).request
      end

      if @skip_payment
        payment.paid_at = Time.now
        payment.notes = 'Payment has been skipped.'
      end

      payment.save!

      # Return the payment
      payment
    end
  end
end
