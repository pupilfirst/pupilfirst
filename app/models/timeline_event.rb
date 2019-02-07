# frozen_string_literal: true

class TimelineEvent < ApplicationRecord
  belongs_to :target
  has_many :target_evaluation_criteria, through: :target
  has_many :evaluation_criteria, through: :target_evaluation_criteria

  has_one :karma_point, as: :source, dependent: :destroy, inverse_of: :source
  has_many :startup_feedback, dependent: :destroy
  has_many :timeline_event_files, dependent: :destroy

  belongs_to :improved_timeline_event, class_name: 'TimelineEvent', optional: true
  has_one :improvement_of, class_name: 'TimelineEvent', foreign_key: 'improved_timeline_event_id', dependent: :nullify, inverse_of: :improved_timeline_event
  has_many :timeline_event_grades, dependent: :destroy
  belongs_to :evaluator, class_name: 'Faculty', optional: true
  has_many :timeline_event_owners, dependent: :destroy
  has_many :founders, through: :timeline_event_owners

  serialize :links

  delegate :founder_event?, to: :target
  delegate :title, to: :target

  MAX_DESCRIPTION_CHARACTERS = 500

  GRADE_GOOD = 'good'
  GRADE_GREAT = 'great'
  GRADE_WOW = 'wow'

  validates :event_on, presence: true
  validates :description, presence: true

  accepts_nested_attributes_for :timeline_event_files, allow_destroy: true

  scope :from_admitted_startups, -> { joins(:founders).where(founders: { startup: Startup.admitted }) }
  scope :not_dropped_out, -> { joins(:founders).where(founders: { startup: Startup.not_dropped_out }) }
  scope :has_image, -> { where.not(image: nil) }
  scope :from_approved_startups, -> { joins(:founders).where(founders: { startup: Startup.approved }) }
  scope :not_private, -> { joins(:target).where.not(targets: { role: Target::ROLE_FOUNDER }) }
  scope :not_improved, -> { joins(:target).where(improved_timeline_event_id: nil) }
  scope :not_auto_verified, -> { joins(:evaluation_criteria).distinct }
  scope :auto_verified, -> { where.not(id: not_auto_verified) }
  scope :passed, -> { where.not(passed_at: nil) }
  scope :pending_review, -> { not_auto_verified.where(evaluator_id: nil) }
  scope :evaluated_by_faculty, -> { where.not(evaluator_id: nil) }
  scope :from_founders, ->(founders) { joins(:timeline_event_owners).where(timeline_event_owners: { founder: founders }) }

  after_initialize :make_links_an_array

  def make_links_an_array
    self.links ||= []
  end

  before_save :ensure_links_is_an_array

  def ensure_links_is_an_array
    self.links = [] if links.nil?
  end

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

  def reviewed?
    timeline_event_grades.present?
  end

  def public_link?
    links.reject { |l| l[:private] }.present?
  end

  def points_for_grade
    minimum_point_for_target = target&.points_earnable
    return minimum_point_for_target if grade.blank?

    multiplier = {
      GRADE_GOOD => 1,
      GRADE_GREAT => 1.5,
      GRADE_WOW => 2
    }.with_indifferent_access[grade]

    minimum_point_for_target * multiplier
  end

  # A hidden timeline event is not displayed to user if user isn't logged in, or isn't the founder linked to event.
  def hidden_from?(viewer)
    return false unless target.founder_event?
    return true if viewer.blank?

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

  def founder_or_startup
    founder_event? ? founder : startup
  end

  def improved_event_candidates
    founder_or_startup.timeline_events
      .where('created_at > ?', created_at)
      .where.not(id: id).order('event_on DESC')
  end

  def share_url
    Rails.application.routes.url_helpers.student_timeline_event_show_url(
      slug: founder.slug,
      event_id: id,
      event_title: title.parameterize
    )
  end

  def image_filename
    return if image.blank?

    image&.sanitized_file&.original_filename
  end

  def first_attachment_url
    @first_attachment_url ||= first_file_url || first_link_url
  end

  def days_elapsed
    start_date = startup.earliest_team_event_date
    return nil if start_date.blank?

    (event_on - start_date).to_i + 1
  end

  def overall_grade_from_score
    return if score.blank?

    { 1 => 'good', 2 => 'great', 3 => 'wow' }[score.floor]
  end

  def startup
    founders.includes(:startup).first.startup
  end

  def founder
    founders.first
  end

  def passed?
    passed_at.present?
  end

  def team_event?
    target.team_target?
  end

  private

  def privileged_founder?(founder)
    founder.present? && startup.founders.include?(founder)
  end

  def first_file_url
    first_file = timeline_event_files.first
    return if first_file.blank?

    Rails.application.routes.url_helpers.download_timeline_event_file_url(first_file)
  end

  def first_link_url
    links.first.try(:[], :url)
  end
end
