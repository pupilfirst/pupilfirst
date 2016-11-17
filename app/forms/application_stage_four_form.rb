class ApplicationStageFourForm < Reform::Form
  property :id
  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, writeable: false
  property :role, validates: { presence: true, inclusion: Founder.valid_roles }
  property :gender, validates: { presence: true, inclusion: Founder.valid_gender_values }
  property :born_on, validates: { presence: true }
  property :parent_name, validates: { presence: true }
  property :permanent_address, validates: { presence: true }
  property :address_proof, validates: { presence: true }
  property :permanent_address_is_current_address, virtual: true
  property :current_address
  property :phone, validates: { presence: true, mobile_number: true }
  property :id_proof_type, validates: { presence: true }
  property :id_proof_number, validates: { presence: true }
  property :id_proof, validates: { presence: true }
  property :income_proof, validates: { presence: true, if: :requires_income_proof? }
  property :letter_from_parent, validates: { presence: true, if: :requires_income_proof? }
  property :college_contact, validates: { presence: true, mobile_number: true, if: :requires_income_proof? }

  # Required in the form to evaluate whether income proof fields are necessary.
  property :fee_payment_method, writeable: false

  def requires_income_proof?
    fee_payment_method.in?(BatchApplicant::REQUIRES_INCOME_PROOF)
  end

  validate :ensure_applicant_is_adult
  validate :current_address_is_available

  def ensure_applicant_is_adult
    return if born_on.blank? # handled by property validator
    return if Time.parse(born_on) <= 18.years.ago
    errors[:born_on] << 'should be more than 18 years ago'
  end

  def current_address_is_available
    return if current_address.present?
    return if permanent_address_is_current_address == '1'
    errors[:current_address] << 'is required'
  end

  def save
    raise NotImplementedError
  end

  def role_options
    Founder.valid_roles.each_with_object([]) do |role, options|
      options << [I18n.t("role.#{role}"), role]
    end
  end

  def gender_options
    Founder.valid_gender_values.each_with_object([]) do |gender, options|
      options << [gender.capitalize, gender]
    end
  end
end
