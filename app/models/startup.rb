# frozen_string_literal: true

class Startup < ApplicationRecord
  include FriendlyId
  include PrivateFilenameRetrievable
  acts_as_taggable

  COURSE_FEE = 50_000

  scope :admitted, -> { joins(:level).where('levels.number > ?', 0) }
  scope :inactive, -> { where('access_ends_at < ?', Time.now).or(where.not(dropped_out_at: nil)) }
  scope :not_dropped_out, -> { where(dropped_out_at: nil) }
  scope :access_active, -> { where('access_ends_at > ?', Time.now).or(where(access_ends_at: nil)) }
  scope :active, -> { not_dropped_out.access_active }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  has_many :founders, dependent: :restrict_with_error
  has_many :startup_feedback, dependent: :destroy
  has_many :connect_requests, dependent: :destroy

  belongs_to :level
  has_one :course, through: :level
  has_one :school, through: :course

  # Faculty who can review this startup's timeline events.
  has_many :faculty_startup_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_startup_enrollments

  # Friendly ID!
  friendly_id :slug_candidates, use: :slugged

  validates :slug, format: { with: /\A[a-z0-9\-_]+\z/i }, allow_nil: true
  validates :name, presence: true

  validates :level, presence: true

  validate :not_assigned_to_level_zero

  def not_assigned_to_level_zero
    errors[:level] << 'cannot be assigned to level zero' unless level.number.positive?
  end

  before_validation do
    # Default product name to 'Untitled Product' if absent
    self.name ||= 'Untitled Product'
  end

  before_destroy do
    # Clear out associations from associated Founders (and pending ones).
    Founder.where(startup_id: id).update_all(startup_id: nil) # rubocop:disable Rails/SkipsModelValidations
  end

  after_create :regenerate_slug

  def founder_ids=(list_of_ids)
    founders_list = Founder.find(list_of_ids.map(&:to_i).select { |e| e.is_a?(Integer) && e.positive? })
    founders_list.each { |u| founders << u }
  end

  def founder?(founder)
    return false unless founder

    founder.startup_id == id
  end

  def possible_founders
    founders + Founder.non_founders
  end

  def cofounders(founder)
    founders - [founder]
  end

  def regenerate_slug
    update_attribute(:slug, nil) # rubocop:disable Rails/SkipsModelValidations
    save!
  end

  def should_generate_new_friendly_id?
    new_record? || slug.nil?
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    parameterized_name = name.parameterize
    [
      parameterized_name,
      [parameterized_name, :id]
    ]
  end

  # returns the date of the earliest verified timeline entry
  def earliest_team_event_date
    timeline_events.where.not(passed_at: nil).not_private.order(:created_at).first.try(:created_at)
  end

  def display_name
    name
  end

  def timeline_events
    TimelineEvent.joins(:timeline_event_owners).where(timeline_event_owners: { founder: founders })
  end

  def active?
    access_ends_at.blank? || (access_ends_at > Time.now)
  end
end
