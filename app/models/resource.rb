# encoding: utf-8
# frozen_string_literal: true

class Resource < ApplicationRecord
  include FriendlyId
  friendly_id :slug_candidates, use: %i(slugged finders)
  acts_as_taggable

  # TODO: Remove association to batch ensuring no loss of data in production
  belongs_to :batch

  belongs_to :startup
  belongs_to :level

  def slug_candidates
    [
      :title,
      %i(title updated_at)
    ]
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  validates :title, presence: true
  validates :description, presence: true

  validate :file_or_video_embed_must_be_present

  def file_or_video_embed_must_be_present
    return if file.present? || video_embed.present?

    errors[:base] << 'A video embed or file is required.'
  end

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader

  scope :public_resources, -> { where(level_id: nil).order('title') }
  # scope to search title
  scope :title_matches, ->(search_key) { where("lower(title) LIKE ?", "%#{search_key.downcase}%") }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i(ransack_tagged_with)
  end

  delegate :content_type, to: :file

  def level_exclusive?
    level.present?
  end

  def stream?
    video_embed.present? || content_type.end_with?('/mp4')
  end

  def increment_downloads(user)
    update!(downloads: downloads + 1)
    if user.present?
      Users::ActivityService.new(user).create(UserActivity::ACTIVITY_TYPE_RESOURCE_DOWNLOAD, 'resource_id' => id)
    end
  end

  after_create :notify_on_slack

  # Notify on slack when a new resource is uploaded
  def notify_on_slack
    if level_exclusive?
      PublicSlackTalk.post_message message: new_resource_message, founders: founders_to_notify
    else
      PublicSlackTalk.post_message message: new_resource_message, channel: '#resources'
    end
  end

  # returns an array of founders who needs to be notified of the new resource
  def founders_to_notify
    if startup.present?
      startup.founders
    elsif level.present?
      Founder.where(startup: Startup.joins(:maximum_level).where('levels.number >= ?', level.number))
    else
      Founder.where(startup: Startup.approved)
    end
  end

  # message to be send to slack for new resources
  def new_resource_message
    message = "*A new #{level_exclusive? ? ('private resource for Level ' + level.number.to_s) : 'public resource'}"\
    " has been uploaded to the SV.CO Startup Library*: \n"
    message += "*Title:* #{title}\n"
    message += "*Description:* #{description}\n"
    message + "*URL:* #{Rails.application.routes.url_helpers.resource_url(self, host: 'https://sv.co')}"
  end

  # ensure titles are capitalized
  before_save do
    self.title = title.titlecase(humanize: false, underscore: false)
  end
end
