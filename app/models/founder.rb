# encoding: utf-8
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
  FEE = 1000

  FEE_ONE_MONTH = 1000
  FEE_THREE_MONTHS = 2000
  FEE_SIX_MONTHS = 3000

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :invitable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  serialize :roles

  has_many :public_slack_messages
  belongs_to :startup, optional: true
  belongs_to :invited_startup, class_name: 'Startup', optional: true
  has_many :karma_points, dependent: :destroy
  has_many :timeline_events
  has_many :visits, as: :user
  has_many :ahoy_events, class_name: 'Ahoy::Event', as: :user
  has_many :platform_feedback
  belongs_to :user
  belongs_to :college, optional: true
  has_one :university, through: :college
  has_many :payments, dependent: :restrict_with_error
  belongs_to :resume_file, class_name: 'TimelineEventFile', optional: true

  scope :admitted, -> { joins(:startup).merge(Startup.admitted) }
  scope :level_zero, -> { joins(:startup).merge(Startup.level_zero) }
  scope :not_dropped_out, -> { joins(:startup).merge(Startup.not_dropped_out) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }
  scope :non_founders, -> { where(startup_id: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  scope :active_on_slack, ->(since, upto) { joins(:public_slack_messages).where(public_slack_messages: { created_at: since..upto }) }
  scope :active_on_web, ->(since, upto) { joins(user: :visits).where(visits: { started_at: since..upto }) }

  scope :inactive, lambda {
    admitted.where(exited: false).where.not(id: active_on_slack(Time.now.beginning_of_week, Time.now)).where.not(id: active_on_web(Time.now.beginning_of_week, Time.now))
  }
  scope :not_exited, -> { where.not(exited: true) }

  def self.with_email(email)
    where('lower(email) = ?', email.downcase).first # rubocop:disable Rails/FindBy
  end

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
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
  # process_in_background :avatar

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
    name.blank? ? email : name
  end

  def name_and_email
    name + (email? ? ' (' + email + ')' : '')
  end

  def to_s
    display_name
  end

  def remove_from_startup!
    team_lead? ? startup.update!(team_lead: nil) : nil
    self.startup_id = nil
    save! validate: false
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

  def activity_date_range
    (activity_timeline_start_date.beginning_of_day..activity_timeline_end_date.end_of_day)
  end

  # Latest of founder creation date or 7 months ago
  def activity_timeline_start_date
    [created_at.to_date, 7.months.ago.to_date].max
  end

  def activity_timeline_end_date
    Date.today
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

  # Make sure a new team lead is assigned before destroying the present one
  before_destroy :assign_new_team_lead

  def assign_new_team_lead
    return unless team_lead? && startup.present?

    team_lead_candidate = startup.founders.where.not(id: id).first
    startup.update!(team_lead: team_lead_candidate)
  end

  # Should we give the founder a tour of the founder dashboard? If so, we shouldn't give it again.
  def tour_dashboard?
    if dashboard_toured
      false
    else
      update!(dashboard_toured: true)
      true
    end
  end

  # method to return the list of active founders on slack for a given duration
  def self.active_founders_on_slack(since:, upto: Time.now)
    Founder.not_dropped_out.not_exited.active_on_slack(since, upto).distinct
  end

  # method to return the list of active founders on web for a given duration
  def self.active_founders_on_web(since:, upto: Time.now)
    Founder.not_dropped_out.not_exited.active_on_web(since, upto).distinct
  end

  def any_targets?
    targets.present? || startup&.targets.present?
  end

  def latest_nps
    platform_feedback.scored.order('created_at').last&.promoter_score
  end

  def promoter?
    latest_nps.present? && latest_nps > 8
  end

  def detractor?
    latest_nps.present? && latest_nps < 7
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
    startup && startup.subscription_active?
  end

  def invited
    invited_startup.present?
  end

  def completed_targets_count
    Targets::BulkStatusService.new(self).completed_targets_count
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

  private

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
end
