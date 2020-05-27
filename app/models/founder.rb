# frozen_string_literal: true

class Founder < ApplicationRecord
  include PrivateFilenameRetrievable

  acts_as_taggable

  COFOUNDER_PENDING = 'pending'
  COFOUNDER_ACCEPTED = 'accepted'
  COFOUNDER_REJECTED = 'rejected'

  # Monthly fee amount for founders.
  FEE = 4000

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :invitable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  serialize :roles

  belongs_to :user
  has_one :school, through: :user
  has_many :public_slack_messages, dependent: :nullify
  belongs_to :startup
  has_one :level, through: :startup
  has_one :course, through: :level
  has_many :communities, through: :course
  has_many :coach_notes, foreign_key: 'student_id', class_name: 'CoachNote', dependent: :destroy, inverse_of: :student
  has_many :visits, as: :user, dependent: :nullify, inverse_of: :user
  has_many :ahoy_events, class_name: 'Ahoy::Event', as: :user, dependent: :nullify, inverse_of: :user
  has_many :platform_feedback, dependent: :nullify
  belongs_to :college, optional: true
  has_one :university, through: :college
  belongs_to :resume_file, class_name: 'TimelineEventFile', optional: true
  has_many :active_admin_comments, as: :resource, class_name: 'ActiveAdmin::Comment', dependent: :destroy, inverse_of: :resource
  has_many :timeline_event_owners, dependent: :destroy
  has_many :timeline_events, through: :timeline_event_owners
  has_many :leaderboard_entries, dependent: :destroy
  has_many :coach_notes, foreign_key: 'student_id', inverse_of: :student, dependent: :restrict_with_error

  has_one_attached :avatar

  scope :admitted, -> { joins(:startup).merge(Startup.admitted) }
  scope :startup_members, -> { where 'startup_id IS NOT NULL' }
  scope :missing_startups, -> { where('startup_id NOT IN (?)', Startup.pluck(:id)) }
  scope :non_founders, -> { where(startup_id: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  scope :active_on_slack, ->(from, to) { joins(:public_slack_messages).where(public_slack_messages: { created_at: from..to }) }
  scope :active_on_web, ->(from, to) { joins(user: :visits).where(visits: { started_at: from..to }) }

  scope :not_dropped_out, -> { joins(:startup).where(startups: { dropped_out_at: nil }) }
  scope :access_active, -> { joins(:startup).where('startups.access_ends_at > ?', Time.zone.now).or(joins(:startup).where(startups: { access_ends_at: nil })) }
  scope :active, -> { not_dropped_out.access_active }

  delegate :email, :name, :title, :affiliation, :about, :avatar, :avatar_variant, :initials_avatar, to: :user

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  def admitted?
    startup.present? && startup.level.number.positive?
  end

  before_validation do
    # Remove blank roles, if any.
    roles.delete('')
  end

  # TODO: Remove this method when all instance of it being used are gone. https://trello.com/c/yh0Mkfir
  def fullname
    name
  end

  normalize_attribute :startup_id, :slack_username

  has_secure_token :auth_token

  def display_name
    name.presence || email
  end

  def name_and_email
    name + ' (' + email + ')'
  end

  def name_and_team
    name + ' (' + startup.name + ')'
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

  def founder?
    startup.present?
  end

  # The option to create connect requests is restricted to non exited founders
  def can_connect?
    startup.present? && !dropped_out?
  end

  def dropped_out?
    startup.dropped_out_at?
  end

  def pending_connect_request_for?(faculty)
    startup.connect_requests.joins(:connect_slot).where(connect_slots: { faculty_id: faculty.id }, status: ConnectRequest::STATUS_REQUESTED).exists?
  end

  def latest_submissions
    timeline_events.where(latest: true)
  end

  def connected_to_slack?
    return false if slack_access_token.blank?

    Founders::SlackConnectService.new(self).token_valid?(slack_access_token)
  end

  def faculty
    return Faculty.none if startup.blank?

    scope = Faculty.left_joins(:startups, :courses)
    scope.where(startups: { id: startup }).or(scope.where(courses: { id: startup.level.course })).distinct
  end

  def access_ended?
    startup.access_ends_at.present? && startup.access_ends_at.past?
  end

  def team_student_ids
    @team_student_ids ||= startup.founder_ids.sort
  end
end
