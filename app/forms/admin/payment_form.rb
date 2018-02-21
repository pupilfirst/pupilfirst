module Admin
  class PaymentForm < Reform::Form
    property :amount, validates: { presence: true }
    property :founder_id, validates: { presence: true }
    property :payment_type, validates: { inclusion: { in: Payment.valid_payment_types }, presence: true }
    property :paid_at, validates: { presence: true }
    property :notes

    def save
      if model.persisted?
        model.update!(attributes)
        model
      else
        Payment.create!(attributes)
      end
    end

    def founder
      if model.persisted?
        model.startup.founders.find(founder_id)
      else
        Founder.find(founder_id)
      end
    end

    def admin_path
      model.persisted? ? view.update_payment_admin_payment_path(model) : view.create_payment_admin_payments_path
    end

    private

    def attributes
      {
        amount: amount,
        founder_id: founder_id,
        payment_type: payment_type,
        paid_at: paid_at,
        notes: notes,
        startup: founder.startup
      }
    end

    def view
      Rails.application.routes.url_helpers
    end
  end
end
