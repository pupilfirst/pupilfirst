class ApplicationStageOneForm < Reform::Form
  property :cofounder_count_select, virtual: true
  property :cofounder_count_number, virtual: true

  validate :cofounder_count_must_be_valid

  def cofounder_count_must_be_valid
    count = cofounder_count_number.present? ? cofounder_count_number : cofounder_count_select
    return if count.to_i.in? (1..9)
    errors[:base] << 'Cofounder count is invalid'
    errors[:cofounder_count] << 'Cofounder count is invalid'
    errors[:cofounder_count_number] << 'Cofounder count is invalid'
  end

  def prepopulate!
    if model.cofounder_count.present?
      if model.cofounder_count.in? [1, 2, 3, 4]
        self.cofounder_count_select = model.cofounder_count.to_s
      else
        self.cofounder_count_select = 'More than 4 (Enter number)'
        self.cofounder_count_number = model.cofounder_count
      end
    end
  end

  def save
    count = cofounder_count_number.present? ? cofounder_count_number : cofounder_count_select
    model.update! cofounder_count: count

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
    Payment.create!(
      batch_application: model,
      batch_applicant: model.team_lead
    )
  end
end
