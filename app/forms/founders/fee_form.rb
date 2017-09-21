module Founders
  class FeeForm < Reform::Form
    property :period, virtual: true, validates: { inclusion: { in: %w[1 3 6] } }

    def save
      Founders::UpdatePendingPaymentService.new(model, period.to_i).update
    end
  end
end
