module Founders
  class FeeForm < Reform::Form
    property :billing_address, virtual: true, validates: { presence: true }
    property :billing_state_id, virtual: true, validates: { presence: true }

    validate :billing_state_must_exist

    def billing_state_must_exist
      return if billing_state.present?
      errors[:billing_state_id] << 'is invalid'
    end

    def save
      # Update founder's billing details if they have changed.
      if startup.billing_state != billing_state || startup.billing_address != billing_address
        startup.update!(billing_state: billing_state, billing_address: billing_address)
      end

      # Update and return payment.
      Founders::UpdatePendingPaymentService.new(model).update
    end

    private

    def startup
      @startup ||= model.startup
    end

    def billing_state
      @billing_state ||= State.find_by(id: billing_state_id)
    end
  end
end
