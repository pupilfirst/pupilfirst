class ApplicationStageOneForm < Reform::Form
  property :team_size_select, virtual: true
  property :team_size_number, virtual: true

  validate :team_size_must_be_valid

  def team_size_must_be_valid
    count = team_size_number.present? ? team_size_number : team_size_select
    return if count.to_i.in?(2..10)
    errors[:base] << 'Team size is invalid'
    errors[:team_size] << 'Team size is invalid'
    errors[:team_size_number] << 'Team size is invalid'
  end

  def prepopulate!
    if model.team_size.present?
      if model.team_size.in? [2, 3, 4, 5]
        self.team_size_select = model.team_size.to_s
      else
        self.team_size_select = 'More than 5 (Enter number)'
        self.team_size_number = model.team_size
      end
    end
  end

  def save
    count = team_size_number.present? ? team_size_number : team_size_select
    model.update! team_size: count

    add_intercom_payment_initiated_tag if Rails.env.production?

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

  def add_intercom_payment_initiated_tag
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: model.team_lead.email, name: model.team_lead.name)
    intercom.add_tag_to_user(user, 'Payment Initiated')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Payment Initiated</em>')

  rescue
    # simply skip for now if anything goes wrong here
    return
  end
end
