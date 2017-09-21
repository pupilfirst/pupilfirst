module Payments
  # Creates a payment entry after contacting Instamojo API.
  #
  # Specifics of how this works can be controlled using options.
  class CreateService
    def initialize(founder, billing_start_at: Time.zone.now)
      @founder = founder
      @startup = founder.startup
      @billing_start_at = billing_start_at
    end

    def create
      payment = Payment.new(
        startup: @startup,
        founder: @founder,
        billing_start_at: @billing_start_at
      )

      payment.save!

      # Return the payment
      payment
    end
  end
end
