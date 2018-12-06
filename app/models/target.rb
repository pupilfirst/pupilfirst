# frozen_string_literal: true

class Target < ApplicationRecord
  # Use to allow archival of a target. See Targets::ArchivalService.
  attr_accessor :safe_to_archive

  # Need to allow these two to be read for AA form.
  attr_reader :startup_id, :founder_id

  KEY_SCREENING = 'screening'
  KEY_COFOUNDER_ADDITION = 'cofounder_addition'
  KEY_R1_TASK = 'r1_task'
  KEY_R1_SHOW_PREVIOUS_WORK = 'r1_show_previous_work'
  KEY_R2_TASK = 'r2_task'
  KEY_ATTEND_INTERVIEW = 'attend_interview'
  KEY_FEE_PAYMENT = 'initial_fee_payment'

  def self.valid_keys
    [KEY_SCREENING, KEY_COFOUNDER_ADDITION, KEY_R1_TASK, KEY_R1_SHOW_PREVIOUS_WORK, KEY_R2_TASK, KEY_ATTEND_INTERVIEW, KEY_FEE_PAYMENT].freeze
  end

  STATUS_COMPLETE = :complete
  STATUS_NEEDS_IMPROVEMENT = :needs_improvement
  STATUS_SUBMITTED = :submitted
  STATUS_PENDING = :pending
  STATUS_UNAVAILABLE = :unavailable # This handles two cases: targets that are not submittable, and ones with prerequisites pending.
  STATUS_NOT_ACCEPTED = :not_accepted
  STATUS_LEVEL_LOCKED = :level_locked # Target is of a higer level
  STATUS_PENDING_MILESTONE = :pending_milestone # Milestone targets of the previous level are incomplete

  UNSUBMITTABLE_STATUSES = [
    STATUS_UNAVAILABLE,
    STATUS_LEVEL_LOCKED,
    STATUS_PENDING_MILESTONE
  ].freeze

  belongs_to :faculty, optional: true
  has_many :timeline_events, dependent: :nullify
  has_many :target_prerequisites, dependent: :destroy
  has_many :prerequisite_targets, through: :target_prerequisites
  belongs_to :target_group
  has_many :target_resources, dependent: :destroy
  has_many :resources, through: :target_resources
  has_many :target_skills, dependent: :destroy
  has_many :skills, through: :target_skills
  has_one :level, through: :target_group
  has_one :course, through: :target_group

  accepts_nested_attributes_for :target_skills, allow_destroy: true

  acts_as_taggable
  mount_uploader :rubric, RubricUploader

  scope :live, -> { joins(:target_group).where(archived: [false, nil]) }
  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_founder, -> { where.not(role: ROLE_FOUNDER) }
  scope :sessions, -> { where.not(session_at: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  ROLE_FOUNDER = 'founder'
  ROLE_TEAM = 'team'

  # See en.yml's target.role
  def self.valid_roles
    [ROLE_FOUNDER, ROLE_TEAM].freeze
  end

  TYPE_TODO = 'Todo'
  TYPE_ATTEND = 'Attend'
  TYPE_READ = 'Read'
  TYPE_LEARN = 'Learn'

  def self.valid_target_action_types
    [TYPE_TODO, TYPE_ATTEND, TYPE_READ, TYPE_LEARN].freeze
  end

  SUBMITTABILITY_RESUBMITTABLE = 'resubmittable'
  SUBMITTABILITY_SUBMITTABLE_ONCE = 'submittable_once'
  SUBMITTABILITY_NOT_SUBMITTABLE = 'not_submittable'
  SUBMITTABILITY_AUTO_VERIFY = 'auto_verify'

  def self.valid_submittability_values
    [SUBMITTABILITY_RESUBMITTABLE, SUBMITTABILITY_SUBMITTABLE_ONCE, SUBMITTABILITY_NOT_SUBMITTABLE, SUBMITTABILITY_AUTO_VERIFY].freeze
  end

  validates :target_action_type, inclusion: { in: valid_target_action_types }, allow_nil: true
  validates :role, presence: true, inclusion: { in: valid_roles }
  validates :title, presence: true
  validates :description, presence: true
  validates :key, uniqueness: true, inclusion: { in: valid_keys }, allow_nil: true
  validates :submittability, inclusion: { in: valid_submittability_values }
  validates :call_to_action, length: { maximum: 20 }

  validate :days_to_complete_or_session_at_should_be_present

  def days_to_complete_or_session_at_should_be_present
    return if [days_to_complete, session_at].one?

    errors[:base] << 'One of days_to_complete, or session_at should be set.'
    errors[:days_to_complete] << 'if blank, session_at should be set'
    errors[:session_at] << 'if blank, days_to_complete should be set'
  end

  validate :avoid_level_mismatch_with_group

  def avoid_level_mismatch_with_group
    return if target_group.blank? || level.blank?
    return if level == target_group.level

    errors[:level] << 'should match level of target group'
  end

  validate :must_be_safe_to_archive

  def must_be_safe_to_archive
    return unless archived_changed? && archived?
    return if safe_to_archive

    errors[:archived] << 'cannot be set unsafely'
  end

  normalize_attribute :key, :slideshow_embed, :video_embed

  def display_name
    if target_group.present?
      "#{course.short_name}##{level.number}: #{title}"
    else
      title
    end
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
    status(founder) == STATUS_PENDING
  end

  def verified?(founder)
    status(founder) == STATUS_COMPLETE
  end

  def stats_service
    @stats_service ||= Targets::StatsService.new(self)
  end

  def session?
    session_at.present?
  end

  def target?
    session_at.blank?
  end

  def founder_event?
    role == ROLE_FOUNDER
  end

  def rubric?
    target_skills.exists? || rubric_url.present?
  end

  # this is included in the target JSONs the DashboardDataService responds with
  alias has_rubric rubric?

  # Returns the latest event linked to this target from a founder. If a team target, it responds with the latest event from the team
  def latest_linked_event(founder, exclude = nil)
    owner = founder_role? ? founder : founder.startup

    owner.timeline_events.where.not(id: exclude).where(target: self).order('created_at').last
  end

  def latest_feedback(founder)
    latest_linked_event(founder)&.startup_feedback&.order('created_at')&.last
  end

  def grades_for_skills(founder)
    return unless verified?(founder)
    return if latest_linked_event(founder).timeline_event_grades.blank?

    latest_linked_event(founder).timeline_event_grades.each_with_object({}) do |te_grade, grades|
      grades[te_grade.skill_id] = te_grade.grade
    end
  end
end
