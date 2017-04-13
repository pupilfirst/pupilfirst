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

      unless @skip_payment || @skip_instamojo
        response = create_instamojo_payment_request

        payment.amount = @startup.fee
        payment.instamojo_payment_request_id = response[:id]
        payment.instamojo_payment_request_status = response[:status]
        payment.short_url = response[:short_url]
        payment.long_url = response[:long_url]
      end

      if @skip_payment
        payment.paid_at = Time.now
        payment.notes = 'Payment has been skipped.'
      end

      payment.save!

      # Return the payment
      payment
    end

    private

    def instamojo
      @instamojo ||= Instamojo.new
    end

    def create_instamojo_payment_request
      instamojo.create_payment_request(
        amount: @startup.fee,
        buyer_name: @founder.name,
        email: @founder.email
      )
    end
  end
end
