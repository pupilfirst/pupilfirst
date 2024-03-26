class Assignment < ApplicationRecord
  belongs_to :target
  has_one :course, through: :target
  has_many :timeline_events, through: :target
  has_one :quiz, dependent: :restrict_with_error
  has_many :assignments_prerequisite_assignments, dependent: :destroy
  has_many :prerequisite_assignments,
           through: :assignments_prerequisite_assignments
  has_many :assignments_evaluation_criteria, dependent: :destroy
  has_many :evaluation_criteria, through: :assignments_evaluation_criteria

  scope :student, -> { where(role: ROLE_STUDENT) }
  scope :not_student, -> { where.not(role: ROLE_STUDENT) }
  scope :team, -> { where(role: ROLE_TEAM) }
  scope :sessions, -> { where.not(session_at: nil) }
  scope :not_archived, -> { where.not(archived: true) }
  scope :milestone, -> { not_archived.where(milestone: true) }

  normalize_attribute :completion_instructions

  ROLE_STUDENT = "student"
  ROLE_TEAM = "team"

  # See en.yml's target.role
  def self.valid_roles
    [ROLE_STUDENT, ROLE_TEAM].freeze
  end

  CHECKLIST_KIND_SHORT_TEXT = "shortText"
  CHECKLIST_KIND_LONG_TEXT = "longText"
  CHECKLIST_KIND_LINK = "link"
  CHECKLIST_KIND_FILES = "files"
  CHECKLIST_KIND_MULTI_CHOICE = "multiChoice"
  CHECKLIST_KIND_AUDIO = "audio"

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

  validates :role, presence: true, inclusion: { in: valid_roles }
  validates_with RateLimitValidator, limit: 2, scope: :target_id

  validate :milestone_should_have_a_number

  def milestone_should_have_a_number
    return unless milestone?

    return if milestone_number.present?

    errors.add(:milestone_number, "must be present for milestone assignments")
  end

  def quiz?
    quiz.present?
  end

  def team_assignment?
    role == ROLE_TEAM
  end

  def individual_assignment?
    role == ROLE_STUDENT
  end

  # Returns the latest submission linked to this target from a student
  def latest_submission(student)
    student.latest_submissions.where(target: self.target).last
  end
end
