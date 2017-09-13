module Founders
  class FeeForm < Reform::Form
    property :period, virtual: true, validates: { inclusion: { in: [1, 6, 12] } }

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
