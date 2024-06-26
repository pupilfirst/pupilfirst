# frozen_string_literal: true

# Schema for Student.metadata:
# {
#   beckn: {
#     "bap_id": string,
#     "bap_uri": "string",
#     "transaction_id": "string",
#    }
# }

class Student < ApplicationRecord
  acts_as_taggable

  belongs_to :user
  has_one :school, through: :user
  belongs_to :cohort
  has_one :course, through: :cohort
  has_many :communities, through: :course
  has_many :coach_notes,
           class_name: "CoachNote",
           dependent: :destroy,
           inverse_of: :student

  has_many :timeline_event_owners, dependent: :destroy
  has_many :timeline_events, through: :timeline_event_owners
  has_many :leaderboard_entries, dependent: :destroy
  has_many :faculty_student_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_student_enrollments
  belongs_to :team, optional: true

  has_many :page_reads, dependent: :destroy

  scope :not_dropped_out, -> { where(dropped_out_at: nil) }
  scope :dropped, -> { where.not(dropped_out_at: nil) }
  scope :access_active, -> { (where(cohort: Cohort.active)) }
  scope :active, -> { access_active.not_dropped_out }
  scope :ended, -> { (where(cohort: Cohort.ended)) }

  validates_with RateLimitValidator,
                 limit: 5000,
                 scope: :cohort_id,
                 time_frame: 1.hour

  delegate :email,
           :name,
           :title,
           :affiliation,
           :about,
           :avatar,
           :avatar_variant,
           :initials_avatar,
           to: :user

  # TODO: Remove this method when all instance of it being used are gone. https://trello.com/c/yh0Mkfir
  def fullname
    name
  end

  normalize_attribute :cohort_id

  has_secure_token :auth_token

  def display_name
    name.presence || email
  end

  def name_and_email
    name + " (" + email + ")"
  end

  def to_s
    display_name
  end

  def latest_submissions
    timeline_events.live.where(timeline_event_owners: { latest: true })
  end

  def access_ended?
    cohort.ended?
  end

  def team_student_ids
    @team_student_ids ||= team.present? ? team.students.pluck(:id).sort : [id]
  end
end
