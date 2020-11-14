# frozen_string_literal: true

class Faculty < ApplicationRecord
  has_secure_token

  belongs_to :user
  has_one :school, through: :user
  has_many :startup_feedback, dependent: :nullify
  has_many :evaluated_events, class_name: 'TimelineEvent', foreign_key: 'evaluator_id', inverse_of: :evaluator, dependent: :nullify
  has_many :targets, dependent: :restrict_with_error
  has_many :connect_slots, dependent: :destroy
  has_many :connect_requests, through: :connect_slots
  has_many :faculty_course_enrollments, dependent: :destroy
  has_many :courses, through: :faculty_course_enrollments

  # Startups whose timeline events this faculty can review.
  has_many :faculty_startup_enrollments, dependent: :destroy
  has_many :startups, through: :faculty_startup_enrollments

  CATEGORY_TEAM = 'team'
  CATEGORY_VISITING_COACHES = 'visiting_coaches'
  CATEGORY_DEVELOPER_COACHES = 'developer_coaches'
  CATEGORY_ADVISORY_BOARD = 'advisory_board'
  CATEGORY_ALUMNI = 'alumni'
  CATEGORY_VR_COACHES = 'vr_coaches'

  COMPENSATION_VOLUNTEER = 'volunteer'
  COMPENSATION_PAID = 'paid'

  COMMITMENT_PART_TIME = 'part_time'
  COMMITMENT_FULL_TIME = 'full_time'

  def self.valid_categories
    [CATEGORY_TEAM, CATEGORY_VISITING_COACHES, CATEGORY_DEVELOPER_COACHES, CATEGORY_ADVISORY_BOARD, CATEGORY_ALUMNI, CATEGORY_VR_COACHES]
  end

  def self.valid_compensation_values
    [COMPENSATION_VOLUNTEER, COMPENSATION_PAID]
  end

  def self.valid_commitment_values
    [COMMITMENT_PART_TIME, COMMITMENT_FULL_TIME]
  end

  validates :category, inclusion: { in: valid_categories }, presence: true
  validates :compensation, inclusion: { in: valid_compensation_values }, allow_blank: true
  validates :commitment, inclusion: { in: valid_commitment_values }, allow_blank: true

  scope :team, -> { where(category: CATEGORY_TEAM).order('sort_index ASC') }
  scope :visiting_coaches, -> { where(category: CATEGORY_VISITING_COACHES).order('sort_index ASC') }
  scope :developer_coaches, -> { where(category: CATEGORY_DEVELOPER_COACHES).order('sort_index ASC') }
  scope :vr_coaches, -> { where(category: CATEGORY_VR_COACHES).order('sort_index ASC') }
  scope :advisory_board, -> { where(category: CATEGORY_ADVISORY_BOARD).order('sort_index ASC') }
  scope :available_for_connect, -> { where(category: [CATEGORY_TEAM, CATEGORY_VISITING_COACHES, CATEGORY_ALUMNI, CATEGORY_VR_COACHES]) }

  delegate :email, :name, :title, :affiliation, :about, :avatar, to: :user

  normalize_attribute :connect_link

  # Returns completed connect requests.
  def past_connect_requests
    connect_requests.completed.order('connect_slots.slot_at DESC')
  end

  validate :slack_username_must_exist

  def slack_username_must_exist
    return if slack_username.blank?
    return unless slack_username_changed?
    return unless Rails.env.production?

    begin
      @new_slack_user_id = FacultyModule::SlackConnectService.new(self).slack_user_id
    rescue PublicSlack::OperationFailureException
      errors.add(:slack_username, "could not be validated using Slack's API. Contact the engineering team.")
    end

    return if @new_slack_user_id.present?

    errors.add(:slack_username, 'does not exist on SV.CO Public Slack. Confirm username and try again.')
  end

  before_save :fetch_slack_user_id

  def fetch_slack_user_id
    return unless slack_username_changed?

    self.slack_user_id = slack_username.present? ? @new_slack_user_id : nil
  end

  def reviewable_startups(course)
    course.startups.admitted
  end

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
