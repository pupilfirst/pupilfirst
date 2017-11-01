class Instamojo
  # Contacts Instamojo to create a new payment request with supplied payment and returns an updated entry.
  class RequestPaymentService
    include Loggable

    def initialize(payment, period)
      @payment = payment
      @period = period
    end

    # @return [Payment] Updated payment, with instamojo payment request details.
    def request
      # Set the payment period and its amount (calculated using the payment period).
      amount = Startups::FeePayableService.new(@payment.startup).fee_payable(period: @period)
      @payment.update!(period: @period, amount: amount)

      # Create a new Instamojo payment request.
      response = create_instamojo_payment_request

      log 'A new payment request has been created by contacting Instamojo.'

      # Then use the returned data to store Instamojo specifics.
      @payment.instamojo_payment_request_id = response[:id]
      @payment.instamojo_payment_request_status = response[:status]
      @payment.short_url = response[:short_url]
      @payment.long_url = response[:long_url]
      @payment.save!

      # Now return it so that it can be used to redirect the user to long_url for payment processing.
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
