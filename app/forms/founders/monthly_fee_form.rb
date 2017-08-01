module Founders
  class MonthlyFeeForm < Reform::Form
    def save
      payment = Founders::PendingPaymentService.new(model).fetch

      # Contact Instamojo to create request.
      payment = if payment.requested?
        Instamojo::VerifyPaymentRequestService.new(payment).verify
      else
        Instamojo::RequestPaymentService.new(payment).request
      end

      # Return updated payment.
      payment
    end
  end
end
