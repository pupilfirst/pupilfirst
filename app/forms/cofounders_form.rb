class CofoundersForm < Reform::Form
  collection :cofounders, populate_if_empty: BatchApplicant do
    property :id
    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :delete, virtual: true
  end

  validate :do_not_delete_all_cofounders
  validate :limit_cofounders_count
  validate :cofounders_must_be_unique
  validate :do_not_repeat_cofounders

  def limit_cofounders_count
    unless cofounders.count.in? 1..9
      errors[:base] << 'You can have maximum 9 cofounders, and a minimum of 1.'
    end
  end

  def do_not_delete_all_cofounders
    unpersisted_cofounders = cofounders.select { |cofounder| !cofounder.model.persisted? }
    return if unpersisted_cofounders.any?

    persisted_cofounders = cofounders.select { |cofounder| cofounder.model.persisted? }
    return if persisted_cofounders.blank?

    return if persisted_cofounders.select do |persisted_cofounder|
      persisted_cofounder.delete != '1'
    end.present?

    errors[:base] << 'You must have at least one cofounder.'
  end

  def cofounders_must_be_unique
    cofounders.each do |cofounder|
      next if cofounder.model.persisted?

      if model.batch.batch_applicants.find_by(email: cofounder.email).present?
        errors[:base] << "An applicant with email #{cofounder.email} already exists in our database. If this is your friend who registered by accident, please ask them to login and revoke application. Mail help@sv.co or use the chat below for any help."
        cofounder.errors[:email] << 'is already associated with an application'
      end
    end
  end

  def do_not_repeat_cofounders
    previous_emails = []
    has_error = false

    cofounders.each do |cofounder|
      if previous_emails.include? cofounder.email
        has_error = true
        cofounder.errors[:email] << 'has been mentioned before'
      else
        previous_emails << cofounder.email
      end
    end

    errors[:base] << "It looks like you've repeated some cofounder email addresses." if has_error
  end

  def prepopulate!
    self.cofounders = [BatchApplicant.new] * (model.team_size - 1) if cofounders.empty?
  end

  def save
    cofounders.each do |cofounder|
      if cofounder.id.present?
        persisted_cofounder = model.cofounders.find(cofounder.id)

        if cofounder.delete == '1'
          persisted_cofounder.destroy!
        else
          persisted_cofounder.update!(name: cofounder.name)
        end
      else
        applicant = BatchApplicant.where(email: cofounder.email).first_or_create!
        applicant.update!(name: cofounder.name)
        model.batch_applicants << applicant
      end
    end

    model.update!(team_size: model.batch_applicants.count)
  end
end
