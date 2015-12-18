class User < ActiveRecord::Base
  extend Forwardable
  include Gravtastic
  gravtastic

  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'
  GENDER_OTHER = 'other'

  COFOUNDER_PENDING = 'pending'
  COFOUNDER_ACCEPTED = 'accepted'
  COFOUNDER_REJECTED = 'rejected'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  serialize :roles

  has_many :public_slack_messages
  has_many :requests
  belongs_to :college
  belongs_to :father, class_name: 'Name'
  belongs_to :startup
  belongs_to :university
  has_many :karma_points, dependent: :destroy
  has_many :timeline_events

  scope :batched, -> { joins(:startup).where.not(startups: { batch_number: nil }) }
  scope :founders, -> { where(is_founder: true).includes(:startup) }
  scope :non_founders, -> { where("is_founder = ? or is_founder IS NULL", false) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :student_entrepreneurs, -> { where(is_founder: true).where.not(university_id: nil) }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }

  # TODO: Remove born_on, and salutation columns if unneccessary.
  # validates_presence_of :born_on
  # validates_presence_of :salutation, message: ''

  validates :first_name,
    presence: true,
    format: { with: /\A[a-z]+\z/i, message: "should be a single name with no special characters or numbers" },
    length: { minimum: 2 }

  validates :last_name,
    presence: true,
    format: { with: /\A[a-z]+\z/i, message: "should be a single name with no special characters or numbers" },
    length: { minimum: 2 }

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }, allow_nil: true

  # Validations during incubation
  validates_presence_of :gender, :born_on, if: ->(user) { user.startup.try(:incubation_step_1?) }
  validates_presence_of :roll_number, if: :university_id

  before_validation do
    self.roll_number = nil unless university.present?

    # Remove blank roles, if any.
    roles.delete('')
  end

  attr_reader :skip_password

  def fullname
    [first_name, last_name].join(' ')
  end

  # hack
  attr_accessor :inviter_name
  attr_accessor :accept_startup
  attr_accessor :full_validation

  after_initialize ->() { @full_validation = false }
  after_update :send_password_change_email, if: :needs_password_change_email?

  # Email is not required for an unregistered 'contact' user.
  def email_required?
    !(invitation_token.present?)
  end

  # Validate presence of e-mail for everyone except contacts with invitation token (unregistered contacts).
  validates_uniqueness_of :email, unless: ->(user) { user.invitation_token.present? }

  # Validate user's PIN (address).
  validates_numericality_of :pin, allow_blank: true, greater_than_or_equal_to: 100_000, less_than_or_equal_to: 999_999 # PIN Code is always 6 digits

  # Store mobile number in a standardized form.
  phony_normalize :phone, default_country_code: 'IN', add_plus: false

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  mount_uploader :college_identification, CollegeIdentificationUploader
  process_in_background :college_identification

  normalize_attribute :startup_id, :invitation_token, :twitter_url, :linkedin_url, :pin, :first_name, :last_name, :slack_username

  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? value.downcase == 'true' : value
  end

  validates :twitter_url, url: true, allow_nil: true
  validates :linkedin_url, url: true, allow_nil: true

  validate :role_must_be_valid
  validate :slack_username_must_exist

  def role_must_be_valid
    roles.each do |role|
      unless User.valid_roles.include? role
        errors.add(:roles, 'contained unrecognized value')
      end
    end
  end

  def slack_username_must_exist
    return if slack_username.blank?
    return unless slack_username_changed?
    response_json = JSON.parse(RestClient.get "https://slack.com/api/users.list?token=#{APP_CONFIG[:vocalist_api_token]}")
    unless response_json['ok']
      errors.add(:slack_username, 'unable to validate username from slack. Please try again')
      return
    end
    valid_names = response_json['members'].map { |m| m['name'] }
    index = valid_names.index slack_username
    if index.present?
      @new_slack_user_id = response_json['members'][index]['id']
      return
    else
      errors.add(:slack_username, 'a user with this mention name does not exist on SV.CO Public Slack')
    end
  end

  before_save :fetch_slack_user_id

  def fetch_slack_user_id
    return unless slack_username_changed?
    self.slack_user_id = slack_username.present? ? @new_slack_user_id : nil
  end

  before_create do
    self.auth_token = SecureRandom.hex(30)
  end

  before_validation :remove_at_symbol_from_slack_username

  def remove_at_symbol_from_slack_username
    return unless slack_username.present? && slack_username.starts_with?('@')
    self.slack_username = slack_username[1..-1]
  end

  validates_uniqueness_of :slack_username, allow_blank: true
  validate :slack_username_format

  def slack_username_format
    return if slack_username.blank?
    username_match = slack_username.match(/^@?([a-z0-9_]+)$/i)
    return if username_match.present?
    errors.add(:slack_username, 'is not valid. Should only contain letters, numbers, and underscores.')
  end

  def display_name
    email || fullname
  end

  def fullname_and_email
    fullname + (email? ? ' (' + email + ')' : '')
  end

  def to_s
    display_name
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
    # skip_confirmation!

    save!
  end

  def remove_from_startup!
    self.startup_id = nil
    self.startup_admin = nil
    self.is_founder = nil
    save!
  end

  def generate_phone_number_verification_code(incoming_phone_number)
    code = SecureRandom.random_number(1_000_000).to_s.ljust(6, '0')

    # Normalize incoming phone number.
    unverified_phone_number = incoming_phone_number.length <= 10 ? "91#{incoming_phone_number}" : incoming_phone_number

    phone_number = if Phony.plausible?(unverified_phone_number, cc: '91')
      PhonyRails.normalize_number incoming_phone_number, country_code: 'IN', add_plus: false
    else
      fail Exceptions::InvalidPhoneNumber, 'Supplied phone number could not be parsed. Please check and try again.'
    end

    # Store the phone number and verification code.
    self.unconfirmed_phone = phone_number
    self.phone_verification_code = code
    save

    [code, phone_number]
  end

  def verify_phone_number(verification_code)
    if unconfirmed_phone? && (verification_code == phone_verification_code)
      # Store 'verified' phone number
      self.phone = unconfirmed_phone
      self.unconfirmed_phone = nil
      self.phone_verification_code = nil
      save
    else
      fail Exceptions::PhoneNumberVerificationFailed, 'Supplied verification code does not match stored values.'
    end
  end

  def_delegator :startup, :present?, :member_of_startup?

  # Add user with given email as co-founder if possible.
  def add_as_founder_to_startup!(email)
    user = User.find_by email: email

    fail Exceptions::UserNotFound unless user

    if user.startup.present?
      if user.startup == startup
        fail Exceptions::UserAlreadyMemberOfStartup
      else
        fail Exceptions::UserAlreadyHasStartup
      end
    else
      startup.founders << user

      UserMailer.cofounder_addition(email, self).deliver_later
    end
  end

  def ready_for_incubation_wizard?
    phone? && startup.present?
  end

  def incubation_parameters_available?
    gender.present? && born_on.present?
  end

  def self.valid_roles
    %w(product engineering marketing governance design)
  end

  def roles
    super || []
  end

  # A simple flag, which returns true if the user signed in less than 15 seconds ago.
  def just_signed_in
    current_sign_in_at > 15.seconds.ago
  end

  def founder?
    is_founder && startup.present? && startup.approved?
  end

  # The option to create connect requests is restricted to team leads of batched, approved startups.
  def can_connect?
    startup.present? && startup.approved? && startup.batched? && startup_admin?
  end

  # The option to view some info about creating connect requests is restricted to non-lead members of batched, approved startups.
  def can_view_connect?
    startup.present? && startup.approved? && startup.batched? && !startup_admin?
  end

  def pending_connect_request_for?(faculty)
    startup.connect_requests.joins(:connect_slot).where(connect_slots: { faculty_id: faculty.id }, status: ConnectRequest::STATUS_REQUESTED).exists?
  end

  def ping_on_slack!(text)
    im_list_json = JSON.parse(RestClient.get "https://slack.com/api/im.list?token=#{APP_CONFIG[:vocalist_api_token]}")
    fail Exceptions::BadSlackConnection, "Could not establish connection with slack" unless im_list_json['ok']
    user_ids = im_list_json['ims'].map { |im| im['user'] }
    index = user_ids.index slack_user_id
    if index.present?
      im_id = im_list_json['ims'][index]['id']
      RestClient.get "https://slack.com/api/chat.postMessage?token=#{APP_CONFIG[:vocalist_api_token]}&channel=#{im_id}&text=#{text}&as_user=true"
    else
      fail Exceptions::InvalidSlackUser, "Could not find corresponding slack user"
    end
  end

  private

  def needs_password_change_email?
    encrypted_password_changed? && persisted?
  end

  def send_password_change_email
    UserMailer.password_changed(self).deliver_later
  end
end
