module Founders
  class MonthlyFeeForm < Reform::Form
    def save
      payment = Founders::PendingPaymentService.new(model).fetch

      # Contact Instamojo to create request.
      unless payment.requested?
        payment = Instamojo::RequestPaymentService.new(payment).request
      end

      # Return updated payment.
      payment
    end
  end
end
