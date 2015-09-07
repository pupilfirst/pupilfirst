class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  belongs_to :timeline_event_type
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :event_on, :startup_id, :iteration, :timeline_event_type, :description
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
  before_validation :record_iteration, :build_description

  attr_accessor :auto_populated
  def build_description
    if !description.present? && auto_populated
      case timeline_event_type.key
      when 'team_formed'
        self.description = 'The founder formed his initial team'
      when 'new_product_deck'
        self.description = 'The team created a new product deck introducing their startup'
      when 'one_liner'
        self.description = self.startup.about
      end
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

  def new_deck?
    timeline_event_type.new_deck?
  end

  def update_and_require_reverification(params)
    params[:verified_at] = nil
    update(params)
  end

  def verify!
    update!(verified_at: Time.now)
    self.startup.update!(presentation_link: self.links[0][:url]) if new_deck? && self.links[0].try(:[],:url).present?
  end

  def unverify!
    update!(verified_at: nil)
  end
end
