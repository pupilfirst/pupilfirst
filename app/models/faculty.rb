# frozen_string_literal: true

class Faculty < ApplicationRecord
  has_secure_token

  belongs_to :user
  has_one :school, through: :user
  has_many :startup_feedback, dependent: :nullify
  has_many :evaluated_events,
           class_name: "TimelineEvent",
           foreign_key: "evaluator_id",
           inverse_of: :evaluator,
           dependent: :nullify
  has_many :faculty_cohort_enrollments, dependent: :destroy
  has_many :cohorts, through: :faculty_cohort_enrollments
  has_many :courses, through: :cohorts

  # Students whose submissions this faculty can review.
  has_many :faculty_student_enrollments, dependent: :destroy
  has_many :students, through: :faculty_student_enrollments

  scope :exited, -> { where(exited: true) }
  scope :active, -> { where(exited: false) }

  CATEGORY_TEAM = "team"
  CATEGORY_VISITING_COACHES = "visiting_coaches"
  CATEGORY_DEVELOPER_COACHES = "developer_coaches"
  CATEGORY_ADVISORY_BOARD = "advisory_board"
  CATEGORY_ALUMNI = "alumni"
  CATEGORY_VR_COACHES = "vr_coaches"

  COMPENSATION_VOLUNTEER = "volunteer"
  COMPENSATION_PAID = "paid"

  COMMITMENT_PART_TIME = "part_time"
  COMMITMENT_FULL_TIME = "full_time"

  def self.valid_categories
    [
      CATEGORY_TEAM,
      CATEGORY_VISITING_COACHES,
      CATEGORY_DEVELOPER_COACHES,
      CATEGORY_ADVISORY_BOARD,
      CATEGORY_ALUMNI,
      CATEGORY_VR_COACHES
    ]
  end

  def self.valid_compensation_values
    [COMPENSATION_VOLUNTEER, COMPENSATION_PAID]
  end

  def self.valid_commitment_values
    [COMMITMENT_PART_TIME, COMMITMENT_FULL_TIME]
  end

  validates :category, inclusion: { in: valid_categories }, presence: true
  validates :compensation,
            inclusion: {
              in: valid_compensation_values
            },
            allow_blank: true
  validates :commitment,
            inclusion: {
              in: valid_commitment_values
            },
            allow_blank: true

  delegate :email, :name, :title, :affiliation, :about, :avatar, to: :user

  normalize_attribute :connect_link

  def connect_link?
    connect_link.present?
  end

  def image_filename
    user.avatar.attached? ? user.avatar.blob.filename.to_s : nil
  end

  def image
    user.avatar
  end
end
