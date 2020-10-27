class Course < ApplicationRecord
  validates :name, presence: true

  belongs_to :school

  has_many :certificates, dependent: :restrict_with_error
  has_many :levels, dependent: :restrict_with_error
  has_many :startups, through: :levels
  has_many :founders, through: :startups
  has_many :users, through: :founders
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :timeline_events, through: :targets
  has_many :evaluation_criteria, dependent: :restrict_with_error
  has_many :faculty_course_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_course_enrollments
  has_many :community_course_connections, dependent: :restrict_with_error
  has_many :communities, through: :community_course_connections
  has_many :course_exports, dependent: :destroy
  has_many :content_blocks, through: :targets
  has_many :course_authors, dependent: :restrict_with_error
  has_many :webhook_deliveries, dependent: :destroy
  has_one :webhook_endpoint, dependent: :destroy

  has_one_attached :thumbnail
  has_one_attached :cover

  scope :featured, -> { where(featured: true) }

  normalize_attribute :about

  PROGRESSION_BEHAVIOR_LIMITED = -'Limited'
  PROGRESSION_BEHAVIOR_UNLIMITED = -'Unlimited'
  PROGRESSION_BEHAVIOR_STRICT = -'Strict'

  VALID_PROGRESSION_BEHAVIORS = [
    PROGRESSION_BEHAVIOR_LIMITED,
    PROGRESSION_BEHAVIOR_UNLIMITED,
    PROGRESSION_BEHAVIOR_STRICT,
  ].freeze

  validates :progression_behavior, inclusion: VALID_PROGRESSION_BEHAVIORS
  validates :progression_limit, numericality: { greater_than: 0, allow_nil: true }

  def short_name
    name[0..2].upcase.strip
  end

  def facebook_share_disabled?
    name.include? 'Apple'
  end

  def ended?
    ends_at.present? && ends_at.past?
  end

  def cover_url
    if cover.attached?
      Rails.application.routes.url_helpers.rails_blob_path(cover, only_path: true)
    end
  end

  def thumbnail_url
    if thumbnail.attached?
      Rails.application.routes.url_helpers.rails_blob_path(thumbnail, only_path: true)
    end
  end

  def team_tags
    startups.active.joins(:tags).distinct('tags.name').pluck('tags.name')
  end

  def strict?
    progression_behavior == PROGRESSION_BEHAVIOR_STRICT
  end
end
