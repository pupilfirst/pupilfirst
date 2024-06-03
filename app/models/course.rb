class Course < ApplicationRecord
  # JSON fields schema:
  #
  # highlights: [
  #   {
  #     icon: string - should match the list of allowed icons
  #     title: string - title for the highlight (150 chars)
  #     description: string - description from the highlight (250 chars)
  #   },
  #   ...
  # ]
  validates :name, presence: true

  belongs_to :school

  has_many :certificates, dependent: :restrict_with_error
  has_many :levels, dependent: :restrict_with_error
  has_many :cohorts, dependent: :restrict_with_error
  has_many :teams, through: :cohorts
  has_many :students, through: :cohorts
  has_many :users, through: :students
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :assignments, through: :targets
  has_many :timeline_events, through: :targets
  has_many :evaluation_criteria, dependent: :restrict_with_error
  has_many :calendars, dependent: :destroy
  has_many :calendar_events, through: :calendars

  has_many :faculty, -> { distinct }, through: :cohorts
  has_many :community_course_connections, dependent: :restrict_with_error
  has_many :communities, through: :community_course_connections
  has_many :course_exports, dependent: :destroy
  has_many :content_blocks, through: :targets
  has_many :course_authors, dependent: :restrict_with_error
  has_many :webhook_deliveries, dependent: :destroy
  has_one :webhook_endpoint, dependent: :destroy
  has_many :applicants, dependent: :destroy
  belongs_to :default_cohort, class_name: "Cohort", optional: true
  has_many :course_ratings, dependent: :destroy
  has_many :courses_course_categories, dependent: :destroy
  has_many :course_categories, through: :courses_course_categories

  has_one_attached :thumbnail
  has_one_attached :cover

  scope :featured, -> { where(featured: true) }
  scope :live, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :access_active,
        -> do
          joins(:cohorts).where(
            "cohorts.ends_at > ? OR cohorts.ends_at IS NULL",
            Time.now
          ).distinct
        end
  scope :ended, -> { live.where.not(id: access_active) }
  scope :active, -> { live.access_active }
  scope :beckn_enabled, -> { live.where(beckn_enabled: true) }

  normalize_attribute :about, :processing_url

  validates :progression_limit, inclusion: 0..4
  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :school_id,
                 time_frame: 1.year

  def short_name
    name[0..2].upcase.strip
  end

  def facebook_share_disabled?
    name.include? "Apple"
  end

  def ended?
    !cohorts.active.exists?
  end

  def cover_url
    if cover.attached?
      Rails.application.routes.url_helpers.rails_public_blob_url(cover)
    end
  end

  def thumbnail_url
    if thumbnail.attached?
      Rails.application.routes.url_helpers.rails_public_blob_url(thumbnail)
    end
  end

  # ToDo: remove this method
  def team_tags
    teams.active.joins(:tags).distinct("tags.name").pluck("tags.name")
  end

  def student_tags
    students.access_active.joins(:tags).distinct("tags.name").pluck("tags.name")
  end

  def user_tags
    users.joins(:tags).distinct("tags.name").pluck("tags.name")
  end

  def archived?
    archived_at.present?
  end

  def live?
    archived_at.blank?
  end

  def rating
    return 5 if course_ratings.empty?

    course_ratings.average(:rating).to_f
  end
end
