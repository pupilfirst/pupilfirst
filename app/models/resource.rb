# encoding: utf-8
# frozen_string_literal: true

class Resource < ApplicationRecord
  include FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]
  acts_as_taggable

  belongs_to :startup, optional: true
  belongs_to :level, optional: true
  belongs_to :target, optional: true

  def slug_candidates
    [
      :title,
      %i[title updated_at]
    ]
  end

  def should_generate_new_friendly_id?
    title_changed? || saved_change_to_title? || super
  end

  validates :title, presence: true
  validates :description, presence: true

  validate :exactly_one_source_must_be_present

  def exactly_one_source_must_be_present
    return if [file, video_embed, link].one?(&:present?)

    errors[:base] << 'One and only one of a video embed, file or link must be present.'
  end

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader

  scope :public_resources, -> { where(level_id: nil).order('title') }
  # scope to search title
  scope :title_matches, ->(search_key) { where("lower(title) LIKE ?", "%#{search_key.downcase}%") }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  delegate :content_type, to: :file

  def level_exclusive?
    level.present?
  end

  def stream?
    return false if link.present?
    video_embed.present? || content_type.end_with?('/mp4')
  end

  def increment_downloads(user)
    update!(downloads: downloads + 1)
    if user.present?
      Users::ActivityService.new(user).create(UserActivity::ACTIVITY_TYPE_RESOURCE_DOWNLOAD, 'resource_id' => id)
    end
  end

  after_create do
    Resources::AfterCreateNotificationJob.perform_later(self)
  end

  before_save do
    # Ensure titles are capitalized.
    self.title = title.titlecase(humanize: false, underscore: false)
    # Store content_type of file in resource
    self.file_content_type = file.content_type
  end
end
