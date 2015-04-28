class User < ActiveRecord::Base
  extend Forwardable

  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'
  GENDER_OTHER = 'other'

  COFOUNDER_PENDING = 'pending'
  COFOUNDER_ACCEPTED = 'accepted'
  COFOUNDER_REJECTED = 'rejected'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # alias_attribute :communication_address, :address  # 13/03/2015 to accomodate change in user address field for older api, need to be removed after sometime

  has_many :requests
  has_many :news, class_name: "News", foreign_key: :user_id
  has_one :mentor, dependent: :destroy
  belongs_to :college
  belongs_to :bank
  belongs_to :father, class_name: 'Name'
  belongs_to :startup
  has_and_belongs_to_many :categories
  has_many :mentor_meetings

  scope :non_founders, -> { where("is_founder = ? or is_founder IS NULL", false) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :student_entrepreneurs, -> { where(is_student: true, is_founder: true) }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }

  # TODO: Remove born_on, title, and salutation columns if unneccessary.
  # validates_presence_of :born_on
  # validates_presence_of :title, if: ->(user){ user.full_validation }
  # validates_presence_of :salutation, message: ''

  # We don't have a full name when we're creating a temporary co-founder account.
  validates_presence_of :fullname, unless: ->(user) { user.pending_startup_id.present? }

  # validations during incubation
  validates_presence_of :gender, :born_on, :communication_address , if: ->(user) {user.startup.incubation_step_1?}

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }, allow_nil: true

  attr_reader :skip_password
  # hack
  attr_accessor :inviter_name
  attr_accessor :accept_startup
  attr_accessor :full_validation
  after_initialize ->() {
    @full_validation = false
  }

  # Email is not required for an unregistered 'contact' user.
  def email_required?
    !(invitation_token.present?)
  end

  nilify_blanks only: [:invitation_token, :twitter_url, :linkedin_url, :pin]

  # Validate presence of e-mail for everyone except contacts with invitation token (unregistered contacts).
  validates_uniqueness_of :email, unless: ->(user) { user.invitation_token.present? }

  # Validate user's PIN (address).
  validates_numericality_of :pin, allow_blank: true, greater_than_or_equal_to: 100000, less_than_or_equal_to: 999999 # PIN Code is always 6 digits

  # Title is essential if user is a mentor.
  validates_presence_of :title, if: Proc.new { |user| user.mentor.present? }

  # Store mobile number in a standardized form.
  phony_normalize :phone, default_country_code: 'IN'

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar
  normalize_attribute :startup_id, :title

  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? value.downcase == 'true' : value
  end

  validates :twitter_url, url: { allow_blank: true }
  validates :linkedin_url, url: { allow_blank: true }

  before_create do
    self.auth_token = SecureRandom.hex(30)
  end

  def display_name
    email || fullname
  end

  def to_s
    display_name
  end

  def self.find_or_initialize_cofounder(email)
    cofounder = find_or_initialize_by(email: email)

    raise Exceptions::UserAlreadyMemberOfStartup, 'User already belongs to a startup, and cannot be added again.' if cofounder.startup
    raise Exceptions::UserHasPendingStartupInvite, 'User has a pending startup invite, and cannot be invited right now.' if cofounder.pending_startup_id

    cofounder
  end

  # Skips setting password and sets invitation_token to allow later registration.
  def save_unregistered_user!
    unless self.persisted?
      # Devise wants a random password, so let's set one for a new user.
      self.skip_password = true

      # Let's store an invitation token which indicates that the user has been invited.
      self.invitation_token = SecureRandom.hex
    end

    # When saving unregistered users, let's not send out a confirmation e-mail.
    #skip_confirmation!

    save!
  end

  def remove_from_startup!
    self.startup_id = nil
    self.startup_admin = nil
    self.is_founder = nil
    save!
  end

  # Returns status of cofounder addition to a supplied startup.
  def cofounder_status(for_startup)
    if pending_startup_id
      COFOUNDER_PENDING
    elsif startup == for_startup
      COFOUNDER_ACCEPTED
    else
      COFOUNDER_REJECTED
    end
  end

  def generate_phone_number_verification_code(incoming_phone_number)
    code = SecureRandom.random_number(1000000).to_s.ljust(6, '0')

    # Normalize incoming phone number.
    unverified_phone_number = incoming_phone_number.length <= 10 ? "91#{incoming_phone_number}" : incoming_phone_number

    phone_number = if Phony.plausible?(unverified_phone_number, cc: '91')
      PhonyRails.normalize_number incoming_phone_number, country_code: 'IN'
    else
      raise Exceptions::InvalidPhoneNumber, 'Supplied phone number could not be parsed. Please check and try again.'
    end

    # Store the phone number and verification code.
    self.phone = phone_number
    self.phone_verified = false
    self.phone_verification_code = code
    self.save

    return code, phone_number
  end

  def verify_phone_number(incoming_phone_number, verification_code)
    # Normalize incoming phone number.
    unverified_phone_number = incoming_phone_number.length <= 10 ? "91#{incoming_phone_number}" : incoming_phone_number

    phone_number = if Phony.plausible?(unverified_phone_number, cc: '91')
      PhonyRails.normalize_number incoming_phone_number, country_code: 'IN'
    else
      raise Exceptions::InvalidPhoneNumber, 'Supplied phone number could not be parsed. Please check and try again.'
    end

    if self.phone == phone_number && verification_code == self.phone_verification_code
      # Set the phone number to verified.
      self.phone_verified = true
      self.phone_verification_code = nil
      self.save
    else
      raise Exceptions::PhoneNumberVerificationFailed, 'Supplied phone number or verification code do not match stored values.'
    end
  end

  def_delegator :startup, :present?, :member_of_startup?
  def_delegator :mentor, :nil?, :not_a_mentor?
  def_delegator :mentor, :present?, :mentor?

  def mentor_pending_verification?
    mentor.try(:verified_at).blank?
  end

  # Phone verification is the final step of the registration process. If that isn't complete, then the mentor is still
  # going through the registration process.
  def mentor_registration_going_on?
    if mentor.present?
      !phone_verified?
    end
  end
end
