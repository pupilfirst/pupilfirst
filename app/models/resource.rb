# encoding: utf-8
# frozen_string_literal: true

class Resource < ActiveRecord::Base
  include FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  belongs_to :batch
  belongs_to :startup

  def slug_candidates
    [:title, [:title, :updated_at]]
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  SHARE_STATUS_PUBLIC = -'public'
  SHARE_STATUS_APPROVED = -'approved'

  def self.valid_share_statuses
    [SHARE_STATUS_PUBLIC, SHARE_STATUS_APPROVED]
  end

  validates_presence_of :file, :title, :description, :share_status
  validates_inclusion_of :share_status, in: valid_share_statuses

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader

  scope :public_resources, -> { where(share_status: SHARE_STATUS_PUBLIC).order('title') }

  delegate :content_type, to: :file

  def self.for(founder)
    if founder&.startup&.approved?
      where(
        'share_status = ? OR (share_status = ? AND batch_id IS ?) OR (share_status = ? AND batch_id = ?)',
        SHARE_STATUS_PUBLIC,
        SHARE_STATUS_APPROVED,
        nil,
        SHARE_STATUS_APPROVED,
        founder.startup&.batch&.id
      ).order('title')
    else
      public_resources
    end
  end

  def for_approved?
    share_status == SHARE_STATUS_APPROVED
  end

  def stream?
    content_type.end_with? '/mp4'
  end

  def increment_downloads!
    self.downloads += 1
    save!
  end

  after_create :notify_on_slack

  # Notify on slack when a new resource is uploaded
  def notify_on_slack
    PublicSlackTalk.post_message message: new_resource_message, channel: '#resources'
  end

  # message to be send to slack for new resources
  def new_resource_message
    message = "*A new #{for_approved? ? 'private resource (for approved startups)' : 'public resource'}"\
    " has been uploaded to SV.CO*: \n"
    message += "*Title:* #{title}\n"
    message += "*Description:* #{description}\n"
    message + "*URL:* #{Rails.application.routes.url_helpers.resource_url(self, host: 'https://sv.co')}"
  end
end
