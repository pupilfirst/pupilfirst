# encoding: utf-8
# frozen_string_literal: true

class Target < ApplicationRecord
  KEY_ADMISSIONS_SCREENING = 'admissions_screening'
  KEY_ADMISSIONS_FEE_PAYMENT = 'admissions_fee_payment'
  KEY_ADMISSIONS_COFOUNDER_ADDITION = 'admissions_cofounder_addition'
  KEY_ADMISSIONS_CODING_TASK = 'admissions_coding_task'
  KEY_ADMISSIONS_VIDEO_TASK = 'admissions_video_task'
  KEY_ADMISSIONS_ATTEND_INTERVIEW = 'admissions_attend_interview'
  KEY_ADMISSIONS_PRE_SELECTION = 'admissions_pre_selection'

  STATUS_COMPLETE = :complete
  STATUS_NEEDS_IMPROVEMENT = :needs_improvement
  STATUS_SUBMITTED = :submitted
  STATUS_PENDING = :pending
  STATUS_UNAVAILABLE = :unavailable
  STATUS_NOT_ACCEPTED = :not_accepted

  belongs_to :assigner, class_name: 'Faculty'
  belongs_to :timeline_event_type, optional: true
  has_many :timeline_events
  has_many :target_prerequisites
  has_many :prerequisite_targets, through: :target_prerequisites
  belongs_to :target_group
  has_one :program_week, through: :target_group
  has_one :batch, through: :target_group
  belongs_to :level

  acts_as_taggable
  mount_uploader :rubric, RubricUploader

  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_founder, -> { where.not(role: ROLE_FOUNDER) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i(ransack_tagged_with)
  end

  ROLE_FOUNDER = 'founder'
  ROLE_TEAM = 'team'

  def self.target_roles
    [ROLE_FOUNDER, ROLE_TEAM].freeze
  end

  # See en.yml's target.role
  def self.valid_roles
    target_roles + Founder.valid_roles
  end

  TYPE_TODO = 'Todo'
  TYPE_ATTEND = 'Attend'
  TYPE_READ = 'Read'
  TYPE_LEARN = 'Learn'

  def self.valid_target_types
    [TYPE_TODO, TYPE_ATTEND, TYPE_READ, TYPE_LEARN].freeze
  end

  SUBMITTABILITY_RESUBMITTABLE = 'resubmittable'
  SUBMITTABILITY_SUBMITTABLE_ONCE = 'submittable_once'
  SUBMITTABILITY_NOT_SUBMITTABLE = 'not_submittable'

  def self.valid_submittability_values
    [SUBMITTABILITY_RESUBMITTABLE, SUBMITTABILITY_SUBMITTABLE_ONCE, SUBMITTABILITY_NOT_SUBMITTABLE].freeze
  end

  # Need to allow these two to be read for AA form.
  attr_reader :startup_id, :founder_id

  validates :target_type, inclusion: { in: valid_target_types }, allow_nil: true
  validates :role, presence: true, inclusion: { in: valid_roles }
  validates :title, presence: true
  validates :description, presence: true
  validates :key, uniqueness: true, allow_nil: true
  validates :submittability, inclusion: { in: valid_submittability_values }

  validate :days_to_complete_or_session_at_should_be_present

  def days_to_complete_or_session_at_should_be_present
    return if days_to_complete.present? || session_at.present?
    errors[:days_to_complete] << 'if blank, session_at should be set'
    errors[:session_at] << 'if blank, days_to_complete should be set'
  end

  validate :type_of_target_must_be_unique

  def type_of_target_must_be_unique
    return if [target_group, session_at, chore].one?
    errors[:base] << 'Target must be one of chore, session or a vanilla target'
  end

  validate :chore_or_session_must_have_level

  def chore_or_session_must_have_level
    return unless chore || session?
    errors[:level] << 'is required for chore/session' if level.blank?
  end

  validate :vanilla_target_must_have_target_group

  def vanilla_target_must_have_target_group
    return if chore || session?
    errors[:target_group] << 'is required if target is not a chore or session' if target_group.blank?
  end

  normalize_attribute :key

  def display_name
    return title if level.blank?
    "L#{level.number}: #{title}"
  end

  def founder_role?
    role == Target::ROLE_FOUNDER
  end

  def rubric_filename
    rubric.sanitized_file.original_filename
  end

  def status(founder)
    @status ||= {}
    @status[founder.id] ||= Targets::StatusService.new(self, founder).status
  end

  def pending?(founder)
    status(founder) == Targets::StatusService::STATUS_PENDING
  end

  def stats_service
    @stats_service ||= Targets::StatsService.new(self)
  end

  def session?
    session_at.present?
  end

  # A 'proper' target is neither a session, nor a chore. These are repeatable across iterations.
  def target?
    !(session? || chore?)
  end

  # this is included in the target JSONs the DashboardDataService responds with
  alias has_rubric rubric?

  def target_type_description
    role = founder_role? ? 'Founder ' : 'Team '
    type = if session?
      'Session'
    elsif chore?
      'Chore'
    else
      'Target'
    end
    role + type
  end
end
