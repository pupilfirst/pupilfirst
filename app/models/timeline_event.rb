# encoding: utf-8
# frozen_string_literal: true

class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  belongs_to :founder
  belongs_to :timeline_event_type
  belongs_to :target

  has_one :karma_point, as: :source
  has_many :timeline_event_files, dependent: :destroy

  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :event_on, :startup_id, :founder_id, :timeline_event_type, :description
  delegate :founder_event?, :title, to: :timeline_event_type

  MAX_DESCRIPTION_CHARACTERS = 300

  VERIFIED_STATUS_PENDING = 'Pending'
  VERIFIED_STATUS_NEEDS_IMPROVEMENT = 'Needs Improvement'
  VERIFIED_STATUS_VERIFIED = 'Verified'
  VERIFIED_STATUS_NOT_ACCEPTED = 'Not Accepted'

  def self.valid_verified_status
    [VERIFIED_STATUS_VERIFIED, VERIFIED_STATUS_PENDING, VERIFIED_STATUS_NEEDS_IMPROVEMENT, VERIFIED_STATUS_NOT_ACCEPTED]
  end

  validates_inclusion_of :verified_status, in: valid_verified_status

  GRADE_GOOD = 'good'
  GRADE_GREAT = 'great'
  GRADE_WOW = 'wow'

  def self.valid_grades
    [GRADE_GOOD, GRADE_GREAT, GRADE_WOW]
  end

  normalize_attribute :grade
  validates_inclusion_of :grade, in: valid_grades, allow_nil: true

  validates_length_of :description,
    maximum: MAX_DESCRIPTION_CHARACTERS,
    message: "must be within #{MAX_DESCRIPTION_CHARACTERS} characters"

  before_validation do
    self.verified_status ||= VERIFIED_STATUS_PENDING
    self.verified_at = nil unless needs_improvement? || verified?
  end

  validates_presence_of :verified_at, if: proc { verified? || needs_improvement? }

  accepts_nested_attributes_for :timeline_event_files, allow_destroy: true

  scope :end_of_iteration_events, -> { where(timeline_event_type: TimelineEventType.end_iteration) }
  scope :batched, -> { joins(:startup).merge(Startup.batched) }
  scope :verified, -> { where(verified_status: VERIFIED_STATUS_VERIFIED) }
  scope :pending, -> { where(verified_status: VERIFIED_STATUS_PENDING) }
  scope :needs_improvement, -> { where(verified_status: VERIFIED_STATUS_NEEDS_IMPROVEMENT) }
  scope :verified_or_needs_improvement, -> { where(verified_status: [VERIFIED_STATUS_VERIFIED, VERIFIED_STATUS_NEEDS_IMPROVEMENT]) }
  scope :has_image, -> { where.not(image: nil) }
  scope :from_approved_startups, -> { joins(:startup).merge(Startup.approved) }
  scope :showcase, -> { includes(:timeline_event_type, :startup).verified.from_approved_startups.batched.not_private.order('timeline_events.event_on DESC') }
  scope :help_wanted, -> { where(timeline_event_type: TimelineEventType.help_wanted) }
  scope :for_batch, -> (batch) { joins(:startup).where(startups: { batch_id: batch.id }) }
  scope :not_private, -> { where(timeline_event_type: TimelineEventType.where.not(role: TimelineEventType::ROLE_FOUNDER)) }

  after_initialize :make_links_an_array

  def make_links_an_array
    self.links ||= []
  end

  before_save :ensure_links_is_an_array

  def ensure_links_is_an_array
    self.links = [] if links.nil?
  end

  before_validation :build_description

  def build_description
    return unless !description.present? && auto_populated
    self.description = case timeline_event_type.key
      when 'joined_svco'
        'We just registered our startup on SV.CO. Looking forward to an amazing learning experience!'
    end
  end

  after_commit do
    startup.update_stage! if timeline_event_type.stage_change?
  end

  attr_accessor :auto_populated

  # Accessors used by timeline builder form to create TimelineEventFile entries.
  # Should contain a hash: { identifier_key => uploaded_file, ... }
  attr_accessor :files

  # Writer used by timeline builder form to supply info about new / to-delete files.
  attr_writer :files_metadata

  def files_metadata
    @files_metadata || []
  end

  def files_metadata_json
    timeline_event_files.map do |file|
      {
        identifier: file.id,
        title: file.title,
        private: file.private?,
        persisted: true
      }
    end.to_json
  end

  # Return serialized links so that AA TimelineEvent#new/edit can use it.
  def serialized_links
    links.to_json
  end

  # Accept links in serialized form.
  def serialized_links=(links_string)
    self.links = JSON.parse(links_string).map(&:symbolize_keys)
  end

  after_save :update_timeline_event_files

  def update_timeline_event_files
    # Go through files metadata, and perform create / delete.
    files_metadata.each do |file_metadata|
      if file_metadata['persisted']
        # Delete persisted files if they've been flagged.
        if file_metadata['delete']
          timeline_event_files.find(file_metadata['identifier']).destroy!
        end
      else
        # Create non-persisted files.
        timeline_event_files.create!(
          title: file_metadata['title'],
          file: files[file_metadata['identifier']],
          private: file_metadata['private']
        )
      end
    end
  end

  def iteration
    startup.iteration(at_event: self)
  end

  def end_iteration?
    timeline_event_type.end_iteration?
  end

  def update_and_require_reverification(params)
    params[:verified_at] = nil
    params[:verified_status] = VERIFIED_STATUS_PENDING
    update(params)
  end

  def verify!
    update!(verified_status: VERIFIED_STATUS_VERIFIED, verified_at: Time.now)

    add_link_for_new_deck!
    add_link_for_new_wireframe!
    add_link_for_new_prototype!
    add_link_for_new_video!
    add_link_for_new_resume!
  end

  def revert_to_pending!
    update!(verified_status: VERIFIED_STATUS_PENDING, verified_at: nil)
  end

  def mark_needs_improvement!
    update!(verified_status: VERIFIED_STATUS_NEEDS_IMPROVEMENT, verified_at: Time.now)
  end

  def mark_not_accepted!
    update!(verified_status: VERIFIED_STATUS_NOT_ACCEPTED, verified_at: nil)
  end

  def verified?
    verified_status == VERIFIED_STATUS_VERIFIED
  end

  def pending?
    verified_status == VERIFIED_STATUS_PENDING
  end

  def needs_improvement?
    verified_status == VERIFIED_STATUS_NEEDS_IMPROVEMENT
  end

  def not_accepted?
    verified_status == VERIFIED_STATUS_NOT_ACCEPTED
  end

  def to_be_graded?
    ([VERIFIED_STATUS_VERIFIED, VERIFIED_STATUS_NEEDS_IMPROVEMENT].include? verified_status) && karma_point.blank?
  end

  def verified_or_needs_improvement?
    verified? || needs_improvement?
  end

  def public_link?
    links.select { |l| !l[:private] }.present?
  end

  def points_for_grade
    {
      GRADE_GOOD => 10,
      GRADE_GREAT => 20,
      GRADE_WOW => 40
    }.with_indifferent_access[grade]
  end

  # A hidden timeline event is not displayed to user if user isn't logged in, or isn't the founder linked to event.
  def hidden_from?(viewer)
    return false unless timeline_event_type.founder_event?
    return true unless viewer.present?
    founder != viewer
  end

  def attachments_for_founder(founder)
    privileged = privileged_founder?(founder)
    attachments = []

    timeline_event_files.each do |file|
      next if file.private? && !privileged
      attachments << { file: file, title: file.title, private: file.private? }
    end

    links.each do |link|
      next if link[:private] && !privileged
      attachments << link
    end

    attachments
  end

  private

  def privileged_founder?(founder)
    founder.present? && startup.founders.include?(founder)
  end

  def add_link_for_new_resume!
    return unless timeline_event_type.resume_submission?

    first_attachment_url do |attachment_url|
      founder.update!(resume_url: attachment_url)
    end
  end

  def add_link_for_new_deck!
    return unless timeline_event_type.new_deck?

    first_attachment_url do |attachment_url|
      startup.update!(presentation_link: attachment_url)
    end
  end

  def add_link_for_new_wireframe!
    return unless timeline_event_type.new_wireframe?

    first_attachment_url do |attachment_url|
      startup.update!(wireframe_link: attachment_url)
    end
  end

  def add_link_for_new_prototype!
    return unless timeline_event_type.new_prototype?

    first_attachment_url do |attachment_url|
      startup.update!(prototype_link: attachment_url)
    end
  end

  def add_link_for_new_video!
    return unless timeline_event_type.new_video?

    first_attachment_url do |attachment_url|
      startup.update!(product_video_link: attachment_url)
    end
  end

  def first_attachment_url
    attachment_url = first_file_url || first_link_url
    return if attachment_url.blank?
    yield attachment_url
  end

  def first_file_url
    first_file = timeline_event_files.first

    Rails.application.routes.url_helpers.download_startup_timeline_event_timeline_event_file_url(
      startup, self, first_file
    ) if first_file.present?
  end

  def first_link_url
    links.first.try(:[], :url)
  end
end
