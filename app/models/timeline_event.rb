class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  belongs_to :timeline_event_type
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :event_on, :startup_id, :timeline_event_type, :description
  attr_accessor :link_url, :link_title, :link_private

  MAX_DESCRIPTION_CHARACTERS = 300

  VERIFIED_STATUS_PENDING = 'Pending'
  VERIFIED_STATUS_NEEDS_IMPROVEMENT = 'Needs Improvement'
  VERIFIED_STATUS_VERIFIED = 'Verified'

  def self.valid_verified_status
    [VERIFIED_STATUS_PENDING, VERIFIED_STATUS_NEEDS_IMPROVEMENT, VERIFIED_STATUS_VERIFIED]
  end

  validates_inclusion_of :verified_status, in: valid_verified_status

  before_validation do
    # default verified_status to pending unless verified_at is present
    if verified_at.present?
      self.verified_status = VERIFIED_STATUS_VERIFIED
    else
      self.verified_status ||= VERIFIED_STATUS_PENDING
    end
  end

  validates_length_of :description,
    maximum: MAX_DESCRIPTION_CHARACTERS,
    message: "must be within #{MAX_DESCRIPTION_CHARACTERS} characters"

  scope :end_of_iteration_events, -> { where(timeline_event_type: TimelineEventType.end_iteration) }
  scope :batched, -> { joins(:startup).where.not(startups: { batch: nil }) }
  scope :verified, -> { where(verified_status: VERIFIED_STATUS_VERIFIED) }

  validate :link_url_format

  LINK_URL_MATCHER = %r{(?:https?//)?(?:www\.)?(?<domain>[\w-]+)\.}

  def link_url_format
    return unless link_url.present? && link_url !~ LINK_URL_MATCHER
    errors.add(:link_url, 'does not look like a valid URL')
  end

  before_save :make_links_an_array, :build_link_json
  before_validation :build_description

  after_commit do
    startup.update_stage! if timeline_event_type.stage_change?
  end

  attr_accessor :auto_populated

  def build_description
    return unless !description.present? && auto_populated

    self.description = case timeline_event_type.key
      when 'team_formed'
        'The founder formed his initial team'
      when 'new_product_deck'
        'The team created a new product deck introducing their startup'
      when 'one_liner'
        startup.product_description
    end
  end

  def build_link_json
    return unless link_title.present? && link_url.present?
    self.links = [{ title: link_title, url: link_url, private: (link_private.present? && link_private != 'false') }]
  end

  def make_links_an_array
    self.links = [] if links.nil?
  end

  def iteration
    startup.iteration(at_event: self)
  end

  def end_iteration?
    timeline_event_type.end_iteration?
  end

  def new_deck?
    timeline_event_type.new_deck?
  end

  def new_wireframe?
    timeline_event_type.new_wireframe?
  end

  def new_prototype?
    timeline_event_type.new_prototype?
  end

  def update_and_require_reverification(params)
    params[:verified_at] = nil
    params[:verified_status] = VERIFIED_STATUS_PENDING
    update(params)
  end

  def verify!
    update!(verified_status: VERIFIED_STATUS_VERIFIED, verified_at: Time.now)
    startup.update!(presentation_link: links[0][:url]) if new_deck? && links[0].try(:[], :url).present?
    startup.update!(wireframe_link: links[0][:url]) if new_wireframe? && links[0].try(:[], :url).present?
    startup.update!(prototype_link: links[0][:url]) if new_prototype? && links[0].try(:[], :url).present?
  end

  def unverify!
    update!(verified_status: VERIFIED_STATUS_PENDING, verified_at: nil)
  end

  def mark_needs_improvement!
    update!(verified_status: VERIFIED_STATUS_NEEDS_IMPROVEMENT, verified_at: nil)
  end

  def verified?
    self.verified_status == VERIFIED_STATUS_VERIFIED
  end

  def pending?
    self.verified_status == VERIFIED_STATUS_PENDING
  end

  def needs_improvement?
    self.verified_status == VERIFIED_STATUS_NEEDS_IMPROVEMENT
  end
end
