class User < ActiveRecord::Base
  has_one :mooc_student, dependent: :restrict_with_error
  belongs_to :university

  has_secure_token :login_token
  after_create :regenerate_login_token

  validates :email, uniqueness: true, format: { with: /@/, message: 'does not look like a valid address!' }

  # Store unconfirmed phone number in a standardized form. Confirmed phone number will be copied from this field.
  phony_normalize :phone, default_country_code: 'IN', add_plus: false

  # Validate the unconfirmed phone number after it has been normalized.
  validates_plausible_phone :phone, normalized_country_code: 'IN', allow_nil: true
end
