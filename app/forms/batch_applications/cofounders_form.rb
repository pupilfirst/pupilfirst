module BatchApplications
  class CofoundersForm < Reform::Form
    collection :cofounders, populate_if_empty: BatchApplicant do
      property :id
      property :name, validates: { presence: true, length: { maximum: 250 } }
      property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: EmailValidator::REGULAR_EXPRESSION, message: "doesn't look like an email" } }
      property :phone, validates: { presence: true, mobile_number: true }
      property :college_id
      property :college_text, validates: { length: { maximum: 250 } }
      property :delete, virtual: true
    end

    validate :do_not_delete_all_cofounders
    validate :limit_cofounders_count
    validate :cofounders_must_be_unique
    validate :do_not_repeat_cofounders
    validate :cofounder_must_have_college_id_or_text

    def limit_cofounders_count
      unless cofounders.count.in? 1..5
        errors[:base] << 'You can have maximum 5 cofounders, and a minimum of 1.'
      end
    end

    def do_not_delete_all_cofounders
      unpersisted_cofounders = cofounders.select { |cofounder| !cofounder.model.persisted? }
      return if unpersisted_cofounders.any?

      persisted_cofounders = cofounders.select { |cofounder| cofounder.model.persisted? }
      return if persisted_cofounders.blank?

      return if persisted_cofounders.select do |persisted_cofounder|
        persisted_cofounder.delete != 'on'
      end.present?

      errors[:base] << 'You must have at least one cofounder.'
    end

    def cofounders_must_be_unique
      cofounders.each do |cofounder|
        next if cofounder.model.persisted?

        batch = model.application_round.batch

        if cofounder.email.present? && batch.batch_applicants.with_email(cofounder.email).present?
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

    def cofounder_must_have_college_id_or_text
      cofounders.each do |cofounder|
        next if cofounder.college_text.present?
        next if College.find_by(id: cofounder.college_id).present?

        errors[:base] << "Please pick a college for #{cofounder.name}."

        if cofounder.college_id.blank?
          cofounder.errors[:college_text] << "can't be blank"
        else
          cofounder.errors[:college_id] << 'must be selected'
        end
      end
    end

    def prepopulate!
      self.cofounders = [BatchApplicant.new] * (model.team_size - 1) if cofounders.empty?
    end

    def save
      cofounders.each do |cofounder|
        if cofounder.id.present?
          update_applicant(cofounder)
        else
          create_applicant(cofounder)
        end
      end

      model.update!(team_size: model.batch_applicants.count)
    end

    def create_applicant(cofounder)
      applicant = BatchApplicant.with_email(cofounder.email).first
      applicant = BatchApplicant.create!(email: cofounder.email) if applicant.blank?
      applicant.update!(college_details(cofounder).merge(name: cofounder.name, phone: cofounder.phone))
      model.batch_applicants << applicant
    end

    def update_applicant(cofounder)
      persisted_cofounder = model.cofounders.find(cofounder.id)

      if cofounder.delete == 'on'
        persisted_cofounder.destroy!
      else
        persisted_cofounder.update!(college_details(cofounder).merge(name: cofounder.name, phone: cofounder.phone))
      end
    end

    def college_details(cofounder)
      if cofounder.college_text.present?
        { college_text: cofounder.college_text }
      else
        { college_id: cofounder.college_id }
      end
    end

    def college_names
      cofounders.each_with_object({}) do |cofounder, names|
        next if cofounder.college_id.nil?
        names[cofounder.college_id] = College.find(cofounder.college_id).name
      end
    end

    def cofounders_for_react
      JSON.parse(cofounders.to_json).map { |c| c.slice('fields', 'errors') }
    end
  end
end
