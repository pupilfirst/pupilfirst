module Founders
  class RegistrationForm < Reform::Form
    include CollegeAddable
    include EmailBounceValidatable

    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
    property :email_confirmation, virtual: true, validates: { presence: true, length: { maximum: 250 }, email: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :reference
    property :reference_text, virtual: true
    property :college_id, validates: { presence: true }
    property :college_text, validates: { length: { maximum: 250 } }

    # Custom validations.
    validate :do_not_reapply
    validate :college_should_exist
    validate :emails_should_match

    # Applicant with application should be blocked from submitting the form. Zhe should login instead.
    def do_not_reapply
      return if email.blank?
      founder = Founder.with_email(email).first

      return if founder&.startup.blank?

      errors[:base] << 'You have already completed this step. Please sign in instead.'
    end

    def college_should_exist
      return if college_id.blank?
      return if college_id == 'other'
      return if College.find(college_id).present?

      errors[:college_id] << 'is invalid'
    end

    def emails_should_match
      return if email == email_confirmation
      errors[:base] << 'Supplied email address and its confirmation do not match.'
      errors[:email_confirmation] << 'email addresses do not match'
    end

    def prepopulate(user)
      prepopulate_from(user.mooc_student)
      prepopulate_from(user.founder)
    end

    def prepopulate_from(entry)
      return if entry.blank?
      self.name = entry.name
      self.email = entry.email
      self.phone = entry.phone
    end

    def save
      founder_params = {
        name: name,
        email: email,
        phone: phone,
        reference: supplied_reference
      }.merge(college_details)

      Founders::RegistrationService.new(founder_params).register
    end

    def supplied_reference
      reference_text.present? ? reference_text : reference
    end
  end
end
