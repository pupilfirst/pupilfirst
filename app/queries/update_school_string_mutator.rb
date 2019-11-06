class UpdateSchoolStringMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :key, validates: { inclusion: { in: SchoolString::VALID_KEYS, message: 'InvalidKey' } }
  property :value

  # 'value' has different validations for different school string types.
  validates :value, length: { maximum: 10_000, message: 'InvalidLengthValue' }, allow_blank: true, if: :agreement?
  validates :value, length: { maximum: 1000, message: 'InvalidLengthValue' }, allow_blank: true, if: :address?
  validates :value, email: { message: 'InvalidValue' }, allow_blank: true, if: :email_address?

  def update_school_string
    SchoolString.transaction do
      if value.present?
        school_string = SchoolString.where(school: current_school, key: key).first_or_initialize
        school_string.value = value.strip
        school_string.save!
      else
        SchoolString.where(school: current_school, key: key).destroy_all
      end
    end
  end

  private

  def agreement?
    key.in?([SchoolString::PrivacyPolicy.key, SchoolString::TermsOfUse.key])
  end

  def address?
    key == SchoolString::Address.key
  end

  def email_address?
    key == SchoolString::EmailAddress.key
  end
end
