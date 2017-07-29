class Instamojo
  class RequestPaymentService
    def initialize(payment)
      @payment = payment
    end

    # @return [Payment] Updated payment, with instamojo payment request details.
    def request
      response = create_instamojo_payment_request

      @payment.instamojo_payment_request_id = response[:id]
      @payment.instamojo_payment_request_status = response[:status]
      @payment.short_url = response[:short_url]
      @payment.long_url = response[:long_url]

      # Now save the payment, and return it.
      @payment.save
      @payment
    end

    private

    def instamojo
      @instamojo ||= Instamojo.new
    end

    def create_instamojo_payment_request
      instamojo.create_payment_request(
        amount: @payment.amount,
        buyer_name: @payment.founder.name,
        email: @payment.founder.email
      )
    end
  end
end
