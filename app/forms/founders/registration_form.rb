module Founders
  class RegistrationForm < Reform::Form
    include CollegeAddable
    include AdmissionsPrepopulatable
    include EmailBounceValidatable

    attr_reader :replacement_hint

    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :reference
    property :reference_text, virtual: true
    property :ignore_email_hint, virtual: true
    property :college_id, validates: { presence: true }
    property :college_text, validates: { length: { maximum: 250 } }

    # Custom validations.
    validate :do_not_reapply
    validate :college_should_exist
    validate :email_should_be_valid

    # Applicant with application should be blocked from submitting the form. Zhe should login instead.
    def do_not_reapply
      return if email.blank?
      founder = Founder.with_email(email)

      return if founder&.startup.blank?

      errors[:base] << 'You have already completed this step. Please sign in instead.'
    end

    def college_should_exist
      return if college_id.blank?
      return if college_id == 'other'
      return if College.find(college_id).present?

      errors[:college_id] << 'is invalid'
    end

    def email_should_be_valid
      email_validation = EmailInquire.validate(email)
      return if email_validation.valid?
      return if ignore_email_hint == 'true'

      if email_validation.hint?
        errors[:base] << 'email could be incorrect'
        @replacement_hint = email_validation.replacement
      else
        errors[:email] << 'email addresses not valid'
      end
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
