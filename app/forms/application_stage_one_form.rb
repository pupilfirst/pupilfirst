class ApplicationStageOneForm < Reform::Form
  property :cofounder_count, validates: { presence: true, inclusion: %w(2 3 4) }

  def save
    model.update!(cofounder_count: cofounder_count)

    # If payment is present
    if model.payment.present?
      # and the amount is the same as last time
      if model.payment.amount == model.fee
        # just return the payment
        model.payment
      else
        # otherwise archive the old one
        model.payment.archive!

        # and create a new payment.
        create_new_payment
      end
    else
      # If payment doesn't exist, create a new one.
      create_new_payment
    end
  end

  def create_new_payment
    Payment.create!(batch_application: model)
  end
end
