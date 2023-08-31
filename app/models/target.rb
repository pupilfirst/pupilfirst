# frozen_string_literal: true

class Target < ApplicationRecord
  # Use to allow changing visibility of a target. See Targets::UpdateVisibilityService.
  attr_accessor :safe_to_change_visibility

  STATUS_COMPLETE = :complete
  STATUS_NEEDS_IMPROVEMENT = :needs_improvement
  STATUS_SUBMITTED = :submitted
  STATUS_PENDING = :pending
  STATUS_UNAVAILABLE = :unavailable # This handles two cases: targets that are not submittable, and ones with prerequisites pending.
  STATUS_NOT_ACCEPTED = :not_accepted
  STATUS_SUBMISSION_LIMIT_LOCKED = :submission_limit_locked # There are more pending submissions than the submission limit for the course
  STATUS_PENDING_MILESTONE = :pending_milestone # Milestone targets of the previous level are incomplete

  UNSUBMITTABLE_STATUSES = [
    STATUS_UNAVAILABLE,
    STATUS_SUBMISSION_LIMIT_LOCKED,
    STATUS_PENDING_MILESTONE
  ].freeze

  has_many :timeline_events, dependent: :restrict_with_error
  has_many :target_prerequisites, dependent: :destroy
  has_many :prerequisite_targets, through: :target_prerequisites
  belongs_to :target_group
  has_many :target_evaluation_criteria, dependent: :destroy
  has_many :evaluation_criteria, through: :target_evaluation_criteria
  has_one :level, through: :target_group
  has_one :course, through: :target_group
  has_one :quiz, dependent: :restrict_with_error
  has_many :topics, dependent: :restrict_with_error
  has_many :resource_versions, as: :versionable, dependent: :restrict_with_error
  has_many :target_versions, dependent: :destroy
  has_many :content_blocks, through: :target_versions
  has_many :text_versions, as: :versionable, dependent: :restrict_with_error

  acts_as_taggable

  scope :live, -> { where(visibility: VISIBILITY_LIVE) }
  scope :draft, -> { where(visibility: VISIBILITY_DRAFT) }
  scope :student, -> { where(role: ROLE_STUDENT) }
  scope :not_student, -> { where.not(role: ROLE_STUDENT) }
  scope :team, -> { where(role: ROLE_TEAM) }
  scope :sessions, -> { where.not(session_at: nil) }
  scope :milestone, -> { live.where(milestone: true) }

  ROLE_STUDENT = "student"
  ROLE_TEAM = "team"

  # See en.yml's target.role
  def self.valid_roles
    [ROLE_STUDENT, ROLE_TEAM].freeze
  end

  TYPE_TODO = "Todo"
  TYPE_ATTEND = "Attend"
  TYPE_READ = "Read"
  TYPE_LEARN = "Learn"

  VISIBILITY_LIVE = "live"
  VISIBILITY_ARCHIVED = "archived"
  VISIBILITY_DRAFT = "draft"

  CHECKLIST_KIND_SHORT_TEXT = "shortText"
  CHECKLIST_KIND_LONG_TEXT = "longText"
  CHECKLIST_KIND_LINK = "link"
  CHECKLIST_KIND_FILES = "files"
  CHECKLIST_KIND_MULTI_CHOICE = "multiChoice"
  CHECKLIST_KIND_AUDIO = "audio"

  def self.valid_target_action_types
    [TYPE_TODO, TYPE_ATTEND, TYPE_READ, TYPE_LEARN].freeze
  end

  def self.valid_visibility_types
    [VISIBILITY_LIVE, VISIBILITY_ARCHIVED, VISIBILITY_DRAFT].freeze
  end

  def self.valid_checklist_kind_types
    [
      CHECKLIST_KIND_FILES,
      CHECKLIST_KIND_LINK,
      CHECKLIST_KIND_LONG_TEXT,
      CHECKLIST_KIND_MULTI_CHOICE,
      CHECKLIST_KIND_SHORT_TEXT,
      CHECKLIST_KIND_AUDIO
    ].freeze
  end

  validates :target_action_type,
            inclusion: {
              in: valid_target_action_types
            },
            allow_nil: true
  validates :role, presence: true, inclusion: { in: valid_roles }
  validates :title, presence: true
  validates :call_to_action, length: { maximum: 20 }
  validates :visibility,
            inclusion: {
              in: valid_visibility_types
            },
            allow_nil: true

  validate :days_to_complete_or_session_at_should_be_present
  validates_with RateLimitValidator, limit: 100, scope: :target_group_id

  def days_to_complete_or_session_at_should_be_present
    return if days_to_complete.blank? && session_at.blank?
    return if [days_to_complete, session_at].one?

    errors.add(:base, "One of days_to_complete, or session_at should be set.")
    errors.add(:days_to_complete, "if blank, session_at should be set")
    errors.add(:session_at, "if blank, days_to_complete should be set")
  end

  validate :avoid_level_mismatch_with_group

  def avoid_level_mismatch_with_group
    return if target_group.blank? || level.blank?
    return if level == target_group.level

    errors.add(:level, "should match level of target group")
  end

  validate :must_be_safe_to_change_visibility

  def must_be_safe_to_change_visibility
    unless visibility_changed? &&
             (visibility.in? [VISIBILITY_DRAFT, VISIBILITY_ARCHIVED])
      return
    end
    return if safe_to_change_visibility

    errors.add(:visibility, "cannot be modified unsafely")
  end

  validate :same_course_for_target_and_evaluation_criteria

  def same_course_for_target_and_evaluation_criteria
    return if evaluation_criteria.blank?

    evaluation_criteria.each do |ec|
      next if ec.course_id == course.id

      errors.add(
        :base,
        "Target and evaluation criterion must belong to same course"
      )
    end
  end

  validate :milestone_should_have_a_number

  def milestone_should_have_a_number
    return unless milestone?

    return if milestone_number.present?

    errors.add(:milestone_number, "must be present for milestone targets")
  end

  normalize_attribute :slideshow_embed,
                      :video_embed,
                      :youtube_video_id,
                      :link_to_complete,
                      :completion_instructions

  def display_name
    if target_group.present?
      "#{course.short_name}##{level.number}: #{title}"
    else
      title
    end
  end

  def title_with_milestone
    return title unless milestone?

    "#{I18n.t("shared.m")}#{milestone_number} - #{title}"
  end

  def status(student)
    @status ||= {}
    @status[student.id] ||= Targets::StatusService.new(self, student).status
  end

  def pending?(student)
    status(student) == STATUS_PENDING
  end

  def verified?(student)
    status(student) == STATUS_COMPLETE
  end

  def session?
    session_at.present?
  end

  def target?
    session_at.blank?
  end

  def quiz?
    quiz.present?
  end

  def team_target?
    role == ROLE_TEAM
  end

  def individual_target?
    role == ROLE_STUDENT
  end

  # Returns the latest submission linked to this target from a student
  def latest_submission(student)
    student.latest_submissions.where(target: self).last
  end

  def live?
    visibility == VISIBILITY_LIVE
  end

  def current_target_version
    target_versions.order(created_at: :desc).first
  end

  def current_content_blocks
    current_target_version.content_blocks
  end
end
