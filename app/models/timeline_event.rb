# frozen_string_literal: true

# JSON fields schema:
#
# checklist: [
#   {
#     kind: string - should match the target checklist kind (shortText, longText, link, files, multiChoice)
#     title: string - title from the target checklist
#     result: string - answer for the question taken from the user
#     status: string - should be one of noAnswer, Passed, Failed.
#   },
#   ...
# ]

class TimelineEvent < ApplicationRecord
  belongs_to :target
  belongs_to :evaluator, class_name: "Faculty", optional: true
  belongs_to :reviewer, class_name: "Faculty", optional: true
  belongs_to :hidden_by, class_name: "User", optional: true

  has_many :evaluation_criteria, through: :target
  has_many :startup_feedback, dependent: :destroy
  has_many :timeline_event_files, dependent: :destroy
  has_many :timeline_event_grades, dependent: :destroy
  has_many :timeline_event_owners, dependent: :destroy
  has_many :students, through: :timeline_event_owners
  has_many :reactions, as: :reactionable, dependent: :destroy
  has_many :moderation_reports, as: :reportable, dependent: :destroy
  has_one :course, through: :target

  has_many :submission_reports,
           foreign_key: "submission_id",
           inverse_of: :submission,
           dependent: :destroy

  has_many :submission_comments,
           dependent: :destroy,
           inverse_of: "submission",
           foreign_key: "submission_id"

  delegate :title, to: :target

  scope :not_auto_verified,
        -> {
          left_joins(:evaluation_criteria)
            .where.not(evaluation_criteria: { id: nil })
            .distinct
        }
  scope :auto_verified, -> { where.not(id: not_auto_verified) }
  scope :passed, -> { where.not(passed_at: nil) }
  scope :live, -> { where(archived_at: nil) }
  scope :failed, -> { where(passed_at: nil).where.not(evaluated_at: nil) }
  scope :pending_review, -> { live.not_auto_verified.where(evaluated_at: nil) }
  scope :evaluated_by_faculty, -> { where.not(evaluated_at: nil) }
  scope :from_students,
        ->(students) {
          joins(:timeline_event_owners).where(
            timeline_event_owners: {
              student: students
            }
          )
        }
  scope :not_hidden, -> { where(hidden_at: nil) }
  scope :discussion_enabled,
        -> {
          joins(target: :assignments).where(
            target: {
              assignments: {
                discussion: true
              }
            }
          )
        }

  CHECKLIST_STATUS_NO_ANSWER = "noAnswer"
  CHECKLIST_STATUS_PASSED = "passed"
  CHECKLIST_STATUS_FAILED = "failed"

  def self.valid_checklist_status
    [
      CHECKLIST_STATUS_NO_ANSWER,
      CHECKLIST_STATUS_PASSED,
      CHECKLIST_STATUS_FAILED
    ].freeze
  end

  # Accessors used by timeline builder form to create TimelineEventFile entries.
  # Should contain a hash: { identifier_key => uploaded_file, ... }
  attr_accessor :files

  def reviewed?
    evaluated_at.present? || passed_at.present?
  end

  def overall_grade_from_score
    return if score.blank?

    { 1 => "good", 2 => "great", 3 => "wow" }[score.floor]
  end

  def student
    students.first
  end

  def passed?
    passed_at.present?
  end

  def evaluated?
    evaluated_at.present?
  end

  def team_submission?
    target.team_target?
  end

  def pending_review?
    passed_at.blank? && evaluated_at.blank?
  end

  def status
    if passed_at.blank?
      evaluated_at.present? ? :failed : :pending
    else
      evaluated_at.present? ? :passed : :marked_as_complete
    end
  end

  def archived?
    archived_at.present?
  end

  def live?
    !archived?
  end

  def actions_url
    repo = students.first.github_repository
    "https://github.com/#{repo}/actions" if repo
  end
end
