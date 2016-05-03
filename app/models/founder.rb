# encoding: utf-8
# frozen_string_literal: true

class Founder < ActiveRecord::Base
  extend FriendlyId
  extend Forwardable
  include Gravtastic
  gravtastic
  acts_as_taggable

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
  belongs_to :father, class_name: 'Name'
  belongs_to :startup
  belongs_to :university
  has_many :karma_points, dependent: :destroy
  has_many :timeline_events
  belongs_to :invited_batch, class_name: 'Batch'
  has_many :visits, as: :user
  has_many :ahoy_events, class_name: 'Ahoy::Event', as: :user
  has_many :targets, dependent: :destroy, as: :assignee

  scope :batched, -> { joins(:startup).merge(Startup.batched) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  # TODO: Do we need this anymore ?
  scope :student_entrepreneurs, -> { where.not(university_id: nil) }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }
  scope :non_founders, -> { where(startup_id: nil) }
  scope :find_by_batch, -> (batch) { joins(:startup).where(startups: { batch_id: batch.id }) }

  # a verified 'phone' implies registration was completed
  scope :registered, -> { where.not(phone: nil) }
  scope :not_registered, -> { where(phone: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  # Founders active last week
  scope :active_on_slack, -> { where(id: PublicSlackMessage.last_week.pluck(:founder_id).uniq) }
  scope :active_on_web, -> { where(id: Visit.last_week.pluck(:user_id).uniq) }
  scope :recently_inactive, -> { where.not(id: active_on_slack).where.not(id: active_on_web) }

  def self.ransackable_scopes(_auth)
    %i(ransack_tagged_with)
  end

  validates_presence_of :born_on

  validate :age_more_than_18

  def age_more_than_18
    errors.add(:born_on, 'must be at least 18 years old') if born_on && born_on > 18.years.ago.end_of_year
  end

  validates :first_name,
    presence: true,
    format: { with: /\A[a-z]+\z/i, message: "Business Name format. Should be a single name with no special characters or numbers" },
    length: { minimum: 2 }

  validates :last_name,
    presence: true,
    format: { with: /\A[a-z]+\z/i, message: "Business Name format. Should be a single name with no special characters or numbers" },
    length: { minimum: 2 }

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }

  # Validations during incubation
  validates_presence_of :roll_number, if: :university_id

  before_validation do
    self.roll_number = nil unless university.present?

    # Remove blank roles, if any.
    roles.delete('')
  end

  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [
      [:first_name, :last_name],
      [:first_name, :last_name, :id]
    ]
  end

  # Remove dashes separating slug candidates.
  def normalize_friendly_id(_string)
    super.delete '-'
  end

  def should_generate_new_friendly_id?
    first_name_changed? || last_name_changed? || super
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

  # Email is not required for an unregistered 'contact' founder.
  def email_required?
    !invitation_token.present?
  end

  # Validate presence of e-mail for everyone except contacts with invitation token (unregistered contacts).
  validates_uniqueness_of :email, unless: ->(founder) { founder.invitation_token.present? }

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  mount_uploader :college_identification, CollegeIdentificationUploader
  process_in_background :college_identification

  mount_uploader :identification_proof, IdentificationProofUploader
  process_in_background :identification_proof

  normalize_attribute :startup_id, :invitation_token, :twitter_url, :linkedin_url, :first_name, :last_name,
    :slack_username, :resume_url

  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? (value.casecmp('true') == 0) : value
  end

  validates :twitter_url, url: true, allow_nil: true
  validates :linkedin_url, url: true, allow_nil: true

  validate :role_must_be_valid
  validate :slack_username_must_exist

  def role_must_be_valid
    roles.each do |role|
      unless Founder.valid_roles.include? role
        errors.add(:roles, 'contained unrecognized value')
      end
    end
  end

  def slack_username_must_exist
    return if slack_username.blank?
    return unless slack_username_changed?
    return if Rails.env.development?

    response_json = JSON.parse(RestClient.get("https://slack.com/api/users.list?token=#{APP_CONFIG[:slack_token]}"))

    unless response_json['ok']
      errors.add(:slack_username, 'unable to validate username from slack. Please try again')
      return
    end

    valid_names = response_json['members'].map { |m| m['name'] }
    index = valid_names.index slack_username

    if index.present?
      @new_slack_user_id = response_json['members'][index]['id']
    else
      errors.add(:slack_username, 'a user with this mention name does not exist on SV.CO Public Slack')
    end
  end

  before_save :fetch_slack_user_id

  def fetch_slack_user_id
    return unless slack_username_changed?
    self.slack_user_id = slack_username.present? ? @new_slack_user_id : nil
  end

  before_save :capitalize_name_fragments

  def capitalize_name_fragments
    return unless first_name_changed? || last_name_changed?
    self.first_name = first_name.capitalize
    self.last_name = last_name.capitalize
  end

  has_secure_token :auth_token

  before_validation :remove_at_symbol_from_slack_username

  def remove_at_symbol_from_slack_username
    return unless slack_username.present? && slack_username.starts_with?('@')
    self.slack_username = slack_username[1..-1]
  end

  validates_uniqueness_of :slack_username, allow_blank: true
  validates_uniqueness_of :phone, allow_blank: true

  validate :unconfirmed_phone_must_be_unique

  def unconfirmed_phone_must_be_unique
    return if unconfirmed_phone.nil?
    return unless unconfirmed_phone_changed?
    return if Founder.find_by(phone: unconfirmed_phone).blank?

    errors[:unconfirmed_phone] << 'is taken. Please enter your personal mobile phone number.'
  end

  validate :slack_username_format

  def slack_username_format
    return if slack_username.blank?
    username_match = slack_username.match(/^@?([\w\.]+)$/)
    return if username_match.present?
    errors.add(:slack_username, 'is not valid. Should only contain letters, numbers, and underscores.')
  end

  def display_name
    fullname.blank? ? email : fullname
  end

  def fullname_and_email
    fullname + (email? ? ' (' + email + ')' : '')
  end

  def to_s
    display_name
  end

  def remove_from_startup!
    self.startup_id = nil
    self.startup_admin = nil
    save! validate: false
  end

  # Store unconfirmed phone number in a standardized form. Confirmed phone number will be copied from this field.
  phony_normalize :unconfirmed_phone, default_country_code: 'IN', add_plus: false

  # Validate the unconfirmed phone number after it has been normalized.
  validates_plausible_phone :unconfirmed_phone, normalized_country_code: 'IN', allow_nil: true

  def generate_phone_number_verification_code!
    self.phone_verification_code = SecureRandom.random_number(1_000_000).to_s.ljust(6, '0')
    self.verification_code_sent_at = Time.now
    save!

    [phone_verification_code, unconfirmed_phone]
  end

  def verify_phone_number!(verification_code)
    if unconfirmed_phone? && (verification_code == phone_verification_code)
      # Store 'verified' phone number
      self.phone = unconfirmed_phone
      self.unconfirmed_phone = nil
      self.phone_verification_code = nil
      save!
    else
      raise Exceptions::PhoneNumberVerificationFailed, 'Supplied verification code does not match stored values.'
    end
  end

  def_delegator :startup, :present?, :member_of_startup?

  # Add founder with given email as co-founder if possible.
  def add_as_founder_to_startup!(email)
    founder = Founder.find_by email: email

    raise Exceptions::FounderNotFound unless founder

    if founder.startup.present?
      exception_class = if founder.startup == startup
        Exceptions::FounderAlreadyMemberOfStartup
      else
        Exceptions::FounderAlreadyHasStartup
      end

      raise exception_class
    else
      founder.startup = startup
      founder.save! validate: false

      FounderMailer.cofounder_addition(email, self).deliver_later
    end
  end

  def self.valid_roles
    %w(product engineering marketing governance design)
  end

  def roles
    super || []
  end

  # A simple flag, which returns true if the founder signed in less than 15 seconds ago.
  def just_signed_in
    current_sign_in_at > 15.seconds.ago
  end

  def founder?
    startup.present? && startup.approved?
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

  # Returns data required to populate /founders/:slug
  def activity_timeline
    all_activity = karma_points.where(created_at: activity_date_range) +
      timeline_events.where(created_at: activity_date_range) +
      public_slack_messages.where(created_at: activity_date_range)

    sorted_activity = all_activity.sort_by(&:created_at)

    sorted_activity.each_with_object(blank_activity_timeline) do |activity, timeline|
      if activity.is_a? PublicSlackMessage
        add_public_slack_message_to_timeline(activity, timeline)
      elsif activity.is_a? TimelineEvent
        add_timeline_event_to_timeline(activity, timeline)
      elsif activity.is_a? KarmaPoint
        add_karma_point_to_timeline(activity, timeline)
      end
    end
  end

  # If founder is part of a batched startup, it returns batch's date range - otherwise founder creation time to 'now'.
  def activity_date_range
    (activity_timeline_start_date.beginning_of_day..activity_timeline_end_date.end_of_day)
  end

  def activity_timeline_start_date
    batch_start_date.future? ? Date.today : batch_start_date
  end

  def activity_timeline_end_date
    batch_end_date.future? ? Date.today : batch_end_date
  end

  # Returns true if any of the social URL are stored. Used on profile page.
  def social_url_present?
    [twitter_url, facebook_url, linkedin_url, personal_website_url, blog_url, angel_co_url, github_url, behance_url].any?(&:present?)
  end

  # Returns the percentage of profile completion as an integer
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def profile_completion_percentage
    score = 20 # a default score given for required fields during registration
    score += 15 if slack_user_id.present? # has a valid slack account associated
    score += 10 if skype_id.present?
    score += 15 if social_url_present? # has atleast 1 social media links
    score += 5 if communication_address.present?
    score += 10 if about.present?
    score += 10 if identification_proof.present?
    score += 15 if resume_url.present? # has uploaded resume
    score
  end

  # Return the 'next-applicable' profile completion instruction as a string
  def profile_completion_instruction
    return 'Join the SV.CO Public Slack and update your slack username!' unless slack_user_id.present?
    return 'Update your Skype Id' unless skype_id.present?
    return 'Provide at-least one of your social profiles!' unless social_url_present?
    return 'Update your communication address!' unless communication_address.present?
    return 'Write a one-liner about yourself!' unless about.present?
    return 'Upload your legal ID proof!' unless identification_proof.present?
    return 'Submit a resume to your timeline to complete your profile!' unless resume_url.present?
  end

  # Return true if the founder already has all required fields for registration
  def already_registered?
    first_name? && last_name? && encrypted_password? && gender? && born_on?
  end

  # Make sure a new team lead is assigned before destroying the present one
  before_destroy :assign_new_team_lead

  def assign_new_team_lead
    return unless startup_admin && startup.present?

    team_lead_candidate = startup.founders.where.not(id: id).first
    team_lead_candidate.update!(startup_admin: true) if team_lead_candidate
  end

  # Only applicable to startup admins, during startup creation.
  def pending_cofounders
    raise StandardError unless startup_admin? && startup.blank?

    Founder.where.not(id: id).where(startup_token: startup_token).order('id ASC')
  end

  # Should we give the founder a tour of the timeline? If so, we shouldn't give it again.
  def tour_timeline?
    if timeline_toured?
      false
    else
      update!(timeline_toured: true)
      true
    end
  end

  # method to return the list of active founders on slack for a given duration
  def self.active_founders_on_slack(since:, upto: Time.now, batch: Batch.current_or_last)
    Founder.find_by_batch(batch).joins(:public_slack_messages).where(public_slack_messages: { created_at: since..upto }).distinct
  end

  # method to return the list of active founders on web for a given duration
  def self.active_founders_on_web(since:, upto: Time.now, batch: Batch.current_or_last)
    Founder.find_by_batch(batch).joins(:visits).where(visits: { started_at: since..upto }).distinct
  end

  def any_targets?
    targets.present? || startup&.targets.present?
  end

  def self.lead_of(startup_token)
    find_by(startup_token: startup_token, startup_admin: true)
  end

  private

  def batch_start_date
    startup.present? && startup.batch.present? ? startup.batch.start_date : created_at.to_date
  end

  def batch_end_date
    startup.present? && startup.batch.present? ? startup.batch.end_date : Date.today
  end

  def blank_activity_timeline
    start_date = activity_timeline_start_date.beginning_of_month
    end_date = activity_timeline_end_date.end_of_month

    first_day_of_each_month = (start_date..end_date).select { |d| d.day == 1 }

    first_day_of_each_month.each_with_object({}) do |first_day_of_month, blank_timeline|
      blank_timeline[first_day_of_month.strftime('%B')] = { counts: (1..WeekOfMonth.total_weeks(first_day_of_month)).each_with_object({}) { |w, o| o[w] = 0 } }
    end
  end

  def add_public_slack_message_to_timeline(activity, timeline)
    month = activity.created_at.strftime('%B')

    increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

    if timeline[month][:list] && timeline[month][:list].last[:type] == :public_slack_message
      timeline[month][:list].last[:count] += 1
    else
      timeline[month][:list] ||= []
      timeline[month][:list] << { type: :public_slack_message, count: 1 }
    end
  end

  def add_timeline_event_to_timeline(activity, timeline)
    month = activity.created_at.strftime('%B')

    increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

    timeline[month][:list] ||= []
    timeline[month][:list] << { type: :timeline_event, timeline_event: activity }
  end

  def add_karma_point_to_timeline(activity, timeline)
    month = activity.created_at.strftime('%B')

    increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

    timeline[month][:list] ||= []
    timeline[month][:list] << { type: :karma_point, karma_point: activity }
  end

  def increment_activity_count(timeline, month, week)
    timeline[month][:counts][week] ||= 0
    timeline[month][:counts][week] += 1
  end

  def needs_password_change_email?
    encrypted_password_was.present? && encrypted_password_changed? && persisted?
  end

  def send_password_change_email
    FounderMailer.password_changed(self).deliver_later
  end
end
