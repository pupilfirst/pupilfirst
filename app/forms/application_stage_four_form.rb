class ApplicationStageFourForm < Reform::Form
  property :id
  property :name
  property :email
  property :role
  property :gender
  property :born_on
  property :parent_name
  property :permanent_address
  property :address_proof
  property :permanent_address_is_current_address, virtual: true
  property :current_address
  property :phone
  property :id_proof_type
  property :id_proof_number
  property :id_proof
  property :income_proof
  property :letter_from_parent
  property :college_contact

  # Required in the form to evaluate whether income proof fields are necessary.
  property :fee_payment_method, writeable: false

  validate :ensure_applicant_is_adult
  # validate :permanent_address_is_available

  def ensure_applicant_is_adult
    return if Time.parse(born_on) <= 18.years.ago
    errors[:born_on] << 'should be more than 18 years ago'
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
      options << [gender.capitalize, role]
    end
  end
end
