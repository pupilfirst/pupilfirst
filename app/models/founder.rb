# frozen_string_literal: true

class Founder < ApplicationRecord
  extend FriendlyId
  extend Forwardable

  include PrivateFilenameRetrievable

  acts_as_taggable

  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'
  GENDER_OTHER = 'other'

  COFOUNDER_PENDING = 'pending'
  COFOUNDER_ACCEPTED = 'accepted'
  COFOUNDER_REJECTED = 'rejected'

  ID_PROOF_TYPES = ['Aadhaar Card', 'Driving License', 'Passport', 'Voters ID'].freeze

  # Monthly fee amount for founders.
  FEE = 4000

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :invitable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  serialize :roles

  has_many :public_slack_messages, dependent: :nullify
  belongs_to :startup, optional: true
  belongs_to :invited_startup, class_name: 'Startup', optional: true
  has_many :karma_points, dependent: :destroy
  has_many :timeline_events, dependent: :nullify
  has_many :visits, as: :user, dependent: :nullify, inverse_of: :user
  has_many :ahoy_events, class_name: 'Ahoy::Event', as: :user, dependent: :nullify, inverse_of: :user
  has_many :platform_feedback, dependent: :nullify
  belongs_to :user
  belongs_to :college, optional: true
  has_one :university, through: :college
  has_many :payments, dependent: :restrict_with_error
  belongs_to :resume_file, class_name: 'TimelineEventFile', optional: true
  has_many :english_quiz_submissions, foreign_key: 'quizee_id', dependent: :destroy, inverse_of: :quizee
  has_many :active_admin_comments, as: :resource, class_name: 'ActiveAdmin::Comment', dependent: :destroy, inverse_of: :resource

  scope :admitted, -> { joins(:startup).merge(Startup.admitted) }
  scope :level_zero, -> { joins(:startup).merge(Startup.level_zero) }
  scope :not_dropped_out, -> { joins(:startup).merge(Startup.not_dropped_out) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }
  scope :non_founders, -> { where(startup_id: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  scope :active_on_slack, ->(from, to) { joins(:public_slack_messages).where(public_slack_messages: { created_at: from..to }) }
  scope :active_on_web, ->(from, to) { joins(user: :visits).where(visits: { started_at: from..to }) }

  scope :inactive, lambda {
    admitted.where(exited: false).where.not(id: active_on_slack(Time.now.beginning_of_week, Time.now)).where.not(id: active_on_web(Time.now.beginning_of_week, Time.now))
  }
  scope :not_exited, -> { where.not(exited: true) }
  scope :screening_score_above, ->(minimum_score) { where("(screening_data ->> 'score')::int >= ?", minimum_score) }

  def self.with_email(email)
    where('lower(email) = ?', email.downcase).first # rubocop:disable Rails/FindBy
  end

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with screening_score_above]
  end

  def self.valid_gender_values
    [GENDER_MALE, GENDER_FEMALE, GENDER_OTHER]
  end

  validates :born_on, presence: true, allow_nil: true
  validates :gender, inclusion: { in: valid_gender_values }, allow_nil: true
  validates :email, uniqueness: true, allow_nil: true
  validates :id_proof_type, inclusion: { in: ID_PROOF_TYPES }, allow_nil: true

  validate :age_more_than_18

  def age_more_than_18
    errors.add(:born_on, 'must be at least 18 years old') if born_on && born_on > 18.years.ago.end_of_year
  end

  def admitted?
    startup.present? && startup.level.number.positive?
  end

  before_validation do
    # Remove blank roles, if any.
    roles.delete('')
  end

  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [
      %i[name],
      %i[name id]
    ]
  end

  # Remove dashes separating slug candidates.
  def normalize_friendly_id(_string)
    super.delete '-'
  end

  def should_generate_new_friendly_id?
    name_changed? || saved_change_to_name? || super
  end

  # TODO: Remove this method when all instance of it being used are gone. https://trello.com/c/yh0Mkfir
  def fullname
    name
  end

  # TODO: Is this hack required?
  attr_accessor :inviter_name
  # Email is not required for an unregistered 'contact' founder.
  #
  # TODO: Possibly useless method.
  def email_required?
    invitation_token.blank?
  end

  mount_uploader :avatar, AvatarUploader

  mount_uploader :college_identification, CollegeIdentificationUploader
  process_in_background :college_identification

  mount_uploader :identification_proof, IdentificationProofUploader
  mount_uploader :address_proof, AddressProofUploader
  mount_uploader :income_proof, IncomeProofUploader
  mount_uploader :letter_from_parent, LetterFromParentUploader

  normalize_attribute :startup_id, :invitation_token, :twitter_url, :linkedin_url, :name, :slack_username, :resume_url,
    :semester, :year_of_graduation, :gender, :id_proof_type

  before_save :capitalize_name_fragments

  def capitalize_name_fragments
    return unless name_changed?

    self.name = name.split.map do |name_fragment|
      name_fragment[0] = name_fragment[0].capitalize
      name_fragment
    end.join(' ')
  end

  has_secure_token :auth_token
  has_secure_token :invitation_token

  def display_name
    name.presence || email
  end

  def name_and_email
    name + (email? ? ' (' + email + ')' : '')
  end

  def name_and_team
    name + ' (' + startup.product_name + ')'
  end

  def to_s
    display_name
  end

  def self.valid_roles
    %w[product engineering design]
  end

  def roles
    super || []
  end

  # A simple flag, which returns true if the founder signed in less than 15 seconds ago.
  def just_signed_in
    return false if user.current_sign_in_at.blank?
    user.current_sign_in_at > 15.seconds.ago
  end

  def founder?
    startup.present? && startup.approved?
  end

  # The option to create connect requests is restricted to team leads of approved startups.
  def can_connect?
    startup.present? && startup.approved? && !level_zero? && team_lead?
  end

  # The option to view some info about creating connect requests is restricted to non-lead members of approved startups.
  def can_view_connect?
    startup.present? && startup.approved? && !level_zero? && !team_lead?
  end

  def pending_connect_request_for?(faculty)
    startup.connect_requests.joins(:connect_slot).where(connect_slots: { faculty_id: faculty.id }, status: ConnectRequest::STATUS_REQUESTED).exists?
  end

  # Returns true if any of the social URL are stored. Used on profile page.
  def social_url_present?
    [twitter_url, linkedin_url, personal_website_url, blog_url, angel_co_url, github_url, behance_url, facebook_url].any?(&:present?)
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
    score += 15 if resume_link.present? # has uploaded resume
    score
  end

  # Return the 'next-applicable' profile completion instruction as a string
  def profile_completion_instruction
    return 'Join the SV.CO Public Slack and update your slack username!' if slack_user_id.blank?
    return 'Update your Skype Id' if skype_id.blank?
    return 'Provide at-least one of your social profiles!' unless social_url_present?
    return 'Update your communication address!' if communication_address.blank?
    return 'Write a one-liner about yourself!' if about.blank?
    return 'Upload your legal ID proof!' if identification_proof.blank?
    return 'Submit a resume to your timeline to complete your profile!' if resume_link.blank?
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Should we give the founder a tour of the founder dashboard? If so, we shouldn't give it again.
  def tour_dashboard?
    if dashboard_toured
      false
    else
      update!(dashboard_toured: true)
      true
    end
  end

  def any_targets?
    targets.present? || startup&.targets.present?
  end

  def facebook_token_available?
    fb_access_token.present? && fb_token_expires_at > Time.now
  end

  def facebook_token_valid?
    facebook_token_available? && Founders::FacebookService.new(self).token_valid?(fb_access_token)
  end

  def connected_to_slack?
    return false if slack_access_token.blank?
    Founders::SlackConnectService.new(self).token_valid?(slack_access_token)
  end

  def facebook_share_eligibility
    return 'not_admitted' if startup.level_zero?
    facebook_token_available? ? 'eligible' : 'token_unavailable'
  end

  def resume_link
    resume_file.present? ? Rails.application.routes.url_helpers.download_timeline_event_file_url(resume_file) : resume_url
  end

  # Override the default method to compute the URL if stored value is blank?
  def resume_url
    @resume_url ||= begin
      if super.present?
        super
      else
        resume_event = timeline_events.verified
          .joins(:timeline_event_type)
          .where(timeline_event_types: { key: TimelineEventType::TYPE_RESUME_SUBMISSION })
          .last

        resume_event&.first_attachment_url
      end
    end
  end

  def profile_complete?
    required_fields = %i[name roles born_on gender parent_name communication_address permanent_address address_proof phone id_proof_type id_proof_number identification_proof]

    required_fields.all? { |field| self[field].present? }
  end

  delegate level_zero?: :startup

  def subscription_active?
    startup&.subscription_active?
  end

  def invited
    invited_startup.present?
  end

  def self.reference_sources
    [
      'Friend', 'Seniors', '#StartinCollege Event', 'Newspaper/Magazine', 'TV', 'SV.CO Blog', 'Instagram', 'Facebook',
      'Twitter', 'Microsoft Student Partner', 'Other (Please Specify)'
    ]
  end

  def team_lead?
    startup&.team_lead_id == id
  end

  def self.valid_references
    [
      'Friend',
      'Seniors',
      '#StartinCollege Event',
      'Newspaper/Magazine',
      'TV',
      'SV.CO Blog',
      'Instagram',
      'Facebook',
      'Twitter',
      'Microsoft Student Partner',
      'SV.CO Team Member',
      'Other (Please Specify)'
    ].freeze
  end
end
