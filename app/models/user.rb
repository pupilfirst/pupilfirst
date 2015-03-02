class User < ActiveRecord::Base
  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'
  GENDER_OTHER = 'other'

  COFOUNDER_PENDING = 'pending'
  COFOUNDER_ACCEPTED = 'accepted'
  COFOUNDER_REJECTED = 'rejected'

  CURRENT_OCCUPATION_SELF_EMPLOYED = 'self_employed'

  def self.valid_current_occupation_values
    [CURRENT_OCCUPATION_SELF_EMPLOYED]
  end

  EDUCATIONAL_QUALIFICATION_BELOW_MATRICULATION = 'below_matriculation'
  EDUCATIONAL_QUALIFICATION_MATRICULATION = 'matriculation'
  EDUCATIONAL_QUALIFICATION_HIGHER_SECONDARY = 'higher_secondary'
  EDUCATIONAL_QUALIFICATION_GRADUATE = 'graduate'
  EDUCATIONAL_QUALIFICATION_POSTGRADUATE = 'postgraduate'

  def self.valid_educational_qualificiations
    [EDUCATIONAL_QUALIFICATION_BELOW_MATRICULATION, EDUCATIONAL_QUALIFICATION_MATRICULATION, EDUCATIONAL_QUALIFICATION_HIGHER_SECONDARY, EDUCATIONAL_QUALIFICATION_GRADUATE, EDUCATIONAL_QUALIFICATION_POSTGRADUATE]
  end

  RELIGION_HINDU = 'hindu'
  RELIGION_MUSLIM = 'muslim'
  RELIGION_CHRISTIAN = 'christian'
  RELIGION_SIKH = 'sikh'
  RELIGION_BUDDHIST = 'buddhist'
  RELIGION_JAIN = 'jain'
  RELIGION_OTHER = 'other'

  def self.valid_religions
    [RELIGION_HINDU, RELIGION_MUSLIM, RELIGION_CHRISTIAN, RELIGION_SIKH, RELIGION_BUDDHIST, RELIGION_JAIN, RELIGION_OTHER]
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable, #:registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :requests
  has_many :news, class_name: "News", foreign_key: :user_id
  has_many :social_ids
  has_one :student_entrepreneur_policy
  has_one :mentor, dependent: :destroy
  belongs_to :bank
  belongs_to :father, class_name: 'Name'
  belongs_to :address
  belongs_to :guardian
  belongs_to :startup
  belongs_to :startup_link_verifier, class_name: "User", foreign_key: "startup_link_verifier_id"
  has_and_belongs_to_many :categories
  has_many :partnerships
  has_many :mentor_meetings

  scope :non_employees, -> { where("startup_id IS NULL") }
  scope :non_founders, -> { where("is_founder = ? or is_founder IS NULL", false) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :contacts, -> { where is_contact: true }
  scope :student_entrepreneurs, -> { where(is_student: true, is_founder: true) }

  #### missing startups ???? whats the use now.
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }

  accepts_nested_attributes_for :social_ids, :father, :address, :guardian

  # Complicated connections linkage for user-to-user relationship. Destroys the connection when either user or contact are deleted.
  has_many :connections, foreign_key: 'user_id', dependent: :destroy
  has_many :occurrences_as_connection, class_name: 'Connection', foreign_key: 'contact_id', dependent: :destroy

  # TODO: Remove born_on, title, and salutation columns if unneccessary.
  # validates_presence_of :born_on
  # validates_presence_of :title, if: ->(user){ user.full_validation }
  # validates_presence_of :salutation, message: ''

  # We don't have a full name when we're creating a temporary co-founder account.
  validates_presence_of :fullname, unless: ->(user) { user.pending_startup_id.present? }

  validates :gender, inclusion: { in: [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER] }, allow_nil: true

  attr_reader :skip_password
  attr_reader :validate_partnership_essential_fields
  # hack
  attr_accessor :inviter_name
  attr_accessor :accept_startup
  attr_accessor :full_validation
  after_initialize ->() {
    @full_validation = false
  }

  # Email is not required for an unregistered 'contact' user.
  def email_required?
    !(is_contact? && invitation_token.present?)
  end

  # Validate presence of e-mail for everyone except contacts with invitation token (unregistered contacts).
  validates_uniqueness_of :email, unless: ->(user) { user.is_contact? && user.invitation_token.present? }

  # Validate the mobile number
  validates_presence_of :phone, if: ->(user) { user.is_contact? }
  validates_uniqueness_of :phone, if: ->(user) { user.is_contact? }

  # Couple of fields essential to forming partnerships. These are validated when partner confirms intent to form partnership.
  validates_presence_of :born_on, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :pan, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :father_or_husband_name, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :mother_maiden_name, if: ->(user) { user.validate_partnership_essential_fields }
  validates_inclusion_of :married, in: [true, false], if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :current_occupation, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :educational_qualification, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :religion, if: ->(user) { user.validate_partnership_essential_fields }
  validates_presence_of :communication_address, if: ->(user) { user.validate_partnership_essential_fields }

  validates_numericality_of :pin, allow_nil: true, greater_than_or_equal_to: 100000, less_than_or_equal_to: 999999 # PIN Code is always 6 digits

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

  validates :twitter_url, url: { allow_nil: true, allow_blank: true }
  validates :linkedin_url, url: { allow_blank: true, allow_nil: true }

  nilify_blanks only: [:invitation_token, :twitter_url, :linkedin_url]

  before_create do
    self.auth_token = SecureRandom.hex(30)
    self.startup_verifier_token = SecureRandom.hex(30)
  end

  class << self
    def find_by_social_record(network, social_id)
      social_record = SocialId.find_by_provider_and_social_id(network.to_s, social_id.to_s)
      return nil if social_record.nil?
      social_record.user
    end
  end

  # Returns fields relevant to a 'contact' User.
  def contact_fields
    attributes.slice('fullname', 'phone', 'email', 'company', 'designation')
  end

  def verify(user)
    return false if user.startup.nil?
    raise "#{fullname} not allowed to verify founders yet" if startup_link_verifier.nil?
    raise "#{fullname} not allowed to verify founders of #{user.startup.name}" if startup != user.startup
    user.update_attributes!(startup_link_verifier: self)
  end

  def verify_self!
    update_attributes!(startup_link_verifier: self)
  end

  def confirm_employee!(is_founder)
    self.update_attributes!(startup_link_verifier_id: self.id, is_founder: is_founder)
  end

  def verified?
    return true if startup_link_verifier
  end

  def approved_message
    return nil if startup.try(:approval_status) and verified?
    return I18n.t('startup_village.messages.startup_approval.link_startup', company_name: startup.try(:name)) unless verified?
    I18n.t('startup_village.messages.startup_approval.from_startup_village', company_name: startup.try(:name))
  end

  def personal_info_submitted?
    return true if self.father
    false
  end

  def personal_info_enabled?
    return false if startup.try(:incorporation_status?)
    return false unless is_founder
    true
  end

  def incorporation_enabled?
    return false if startup.try(:incorporation_status?)
    return true if is_founder and personal_info_submitted?
    false
  end

  def bank_details_enabled?
    return false if startup.try(:bank_status?)
    return true if is_founder and startup.try(:incorporation_submited?) and personal_info_submitted?
    false
  end

  def sep_enabled?
    is_student?
  end

  #
  # def gender
  #   if salutation == 'Mr'
  #     :male
  #   else
  #     :female
  #   end
  # end

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

  # Creates a contact user, from given sv_user with contact_params and supplied direction of contact.
  #
  # @param [User] sv_user User for / from whom contact is created
  # @param [Hash] contact_params Parameters with which to create contact User.
  # @param [String] direction Direction of connection. See Connection::DIRECTION_*
  # @return [User] Newly created contact user
  def self.create_contact!(sv_user, contact_params, direction)
    # Normalize incoming phone number.
    unverified_phone_number = contact_params[:phone].length <= 10 ? "91#{contact_params[:phone]}" : contact_params[:phone]

    # Pass only plausible phone numbers.
    unless Phony.plausible?(unverified_phone_number, cc: '91')
      raise Exceptions::InvalidPhoneNumber, 'Supplied phone number could not be parsed. Please check and try again.'
    end

    # Create the user
    user = new(contact_params.merge(is_contact: true))
    user.save_unregistered_user!

    # Create the connection
    Connection.create! user_id: sv_user.id, contact_id: user.id, direction: direction
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

  def update_partnership_fields(partnership_essential_user_params)
    @validate_partnership_essential_fields = true

    update(partnership_essential_user_params)
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

  def member_of_startup?
    startup.present?
  end

  def not_a_mentor?
    !mentor?
  end

  def mentor?
    mentor.present?
  end

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
