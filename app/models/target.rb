# encoding: utf-8
# frozen_string_literal: true

class Target < ApplicationRecord
  KEY_ADMISSIONS_SCREENING = 'admissions_screening'
  KEY_ADMISSIONS_FEE_PAYMENT = 'admissions_fee_payment'
  KEY_ADMISSIONS_COFOUNDER_ADDITION = 'admissions_cofounder_addition'
  KEY_ADMISSIONS_ATTEND_INTERVIEW = 'admissions_attend_interview'

  STATUS_COMPLETE = :complete
  STATUS_NEEDS_IMPROVEMENT = :needs_improvement
  STATUS_SUBMITTED = :submitted
  STATUS_PENDING = :pending
  STATUS_UNAVAILABLE = :unavailable
  STATUS_NOT_ACCEPTED = :not_accepted

  belongs_to :faculty
  belongs_to :timeline_event_type, optional: true
  has_many :timeline_events
  has_many :target_prerequisites
  has_many :prerequisite_targets, through: :target_prerequisites
  belongs_to :target_group, optional: true
  belongs_to :level, optional: true
  has_many :resources
  has_many :target_skills
  has_many :skills, through: :target_skills

  accepts_nested_attributes_for :target_skills, allow_destroy: true

  acts_as_taggable
  mount_uploader :rubric, RubricUploader

  scope :live, -> { where(archived: [false, nil]) }
  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_founder, -> { where.not(role: ROLE_FOUNDER) }
  scope :vanilla_targets, -> { where.not(target_group_id: nil) }
  scope :chores, -> { where(chore: true) }
  scope :sessions, -> { where.not(session_at: nil) }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
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

  def self.valid_target_action_types
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

  validates :target_action_type, inclusion: { in: valid_target_action_types }, allow_nil: true
  validates :role, presence: true, inclusion: { in: valid_roles }
  validates :title, presence: true
  validates :description, presence: true
  validates :key, uniqueness: true, allow_nil: true
  validates :submittability, inclusion: { in: valid_submittability_values }

  validate :days_to_complete_or_session_at_should_be_present

  def days_to_complete_or_session_at_should_be_present
    return if [days_to_complete, session_at].one?
    errors[:base] << 'One of days_to_complete, or session_at should be set.'
    errors[:days_to_complete] << 'if blank, session_at should be set'
    errors[:session_at] << 'if blank, days_to_complete should be set'
  end

  validate :vanilla_targets_must_be_in_a_group

  def vanilla_targets_must_be_in_a_group
    return if session?
    return if target_group.present?
    errors[:base] << 'Vanilla targets and chores must be in a target group.'
  end

  validate :can_be_one_of_chore_or_session

  def can_be_one_of_chore_or_session
    return if [session_at, chore].one? || [session_at, chore].none?
    errors[:base] << "Target can be a chore, a session, or neither, but not both. Sessions are treated as chores anyway, since they don't need to be repeated."
  end

  validate :session_must_have_level

  def session_must_have_level
    return unless session?
    return if level.present?
    errors[:level] << 'is required for a session' if level.blank?
  end

  validate :avoid_level_mismatch_with_group

  def avoid_level_mismatch_with_group
    return if target_group.blank? || level.blank?
    return if level == target_group.level
    errors[:level] << 'should match level of target group'
  end

  normalize_attribute :key, :slideshow_embed, :video_embed

  def display_name
    if level.present?
      "L#{level.number}: #{title}"
    elsif target_group.present?
      "L#{target_group.level.number}: #{title}"
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
    status(founder) == Targets::StatusService::STATUS_PENDING
  end

  def stats_service
    @stats_service ||= Targets::StatsService.new(self)
  end

  def target_type
    return :chore if chore?
    session_at.present? ? :session : :target
  end

  def session?
    target_type == :session
  end

  # A 'proper' target is neither a session, nor a chore. These are repeatable across iterations.
  def target?
    target_type == :target
  end

  def rubric?
    skills.present? || rubric_url.present?
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

  # Returns the latest event linked to this target from a founder. If a team target, it responds with the latest event from the team
  def latest_linked_event(founder)
    owner = founder_role? ? founder : founder.startup
    linked_events = owner.timeline_events.where(target: self)

    # Account for iteration if vanilla target.
    if target? && target_group&.level == founder.startup.level
      linked_events = linked_events.where(iteration: founder.startup.iteration)
    end

    linked_events.order('created_at').last
  end

  def latest_feedback(founder)
    latest_linked_event(founder)&.startup_feedback&.order('created_at')&.last
  end
end
