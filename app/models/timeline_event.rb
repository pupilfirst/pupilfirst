class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  belongs_to :timeline_event_type
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :event_on, :startup_id, :iteration, :timeline_event_type, :description
  attr_accessor :link_url, :link_title

  MAX_DESCRIPTION_CHARACTERS = 300

  validates_length_of :description, maximum: MAX_DESCRIPTION_CHARACTERS,
    message: "must be within #{MAX_DESCRIPTION_CHARACTERS} characters"

  scope :batched, -> { joins(:startup).where.not(startups: { batch: nil }) }
  scope :verified, -> { where.not(verified_at: nil) }

  validate :link_url_format

  LINK_URL_MATCHER = /(?:https?\/\/)?(?:www\.)?(?<domain>[\w-]+)\./

  def link_url_format
    if link_url.present? && link_url !~ LINK_URL_MATCHER
      self.errors.add(:link_url, 'does not look like a valid URL')
    end
  end

  before_save :make_links_an_array, :build_link_json
  before_validation :build_default_title_from_type, :record_iteration

  def build_default_title_from_type
    unless title.present?
      self.title = self.timeline_event_type.try(:title)
    end
  end

  def record_iteration
    self.iteration = self.startup.try(:current_iteration)
  end

  def build_link_json
    if link_title.present? && link_url.present?
      self.links = [{ title: link_title, url: link_url }]
    end
  end

  def make_links_an_array
    self.links = [] if links.nil?
  end

  def verified?
    verified_at.present?
  end

  def end_iteration?
    timeline_event_type.end_iteration?
  end

  def update_and_require_reverification(params)
    params[:verified_at] = nil
    update(params)
  end

  def verify!
    update!(verified_at: Time.now)
  end

  def unverify!
    update!(verified_at: nil)
  end
end
