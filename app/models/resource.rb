# frozen_string_literal: true

class Resource < ApplicationRecord
  include FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]
  acts_as_taggable

  belongs_to :school
  has_many :target_resources, dependent: :destroy
  has_many :targets, through: :target_resources
  has_one_attached :file_as

  def slug_candidates
    [
      :title,
      %i[title id]
    ]
  end

  def should_generate_new_friendly_id?
    title_changed? || saved_change_to_title? || super
  end

  validates :title, presence: true
  validates :description, presence: true

  validate :exactly_one_source_must_be_present

  def exactly_one_source_must_be_present
    return if [file_as.attached?, video_embed.present?, link.present?].one?
    return if persisted?

    errors[:base] << 'One and only one of a video embed, file or link must be present.'
  end

  mount_uploader :file, ResourceFileUploader

  scope :public_resources, -> { where(public: true).order('title') }
  # scope to search title
  scope :title_matches, ->(search_key) { where("lower(title) LIKE ?", "%#{search_key.downcase}%") }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  scope :live, -> { where(archived: [false, nil]) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  def stream?
    return false if link.present?

    video_embed.present? || file_content_type&.end_with?('/mp4')
  end

  def file_url
    file_as.attached? && Rails.application.routes.url_helpers.rails_blob_path(file_as, only_path: true)
  end

  def increment_downloads(user)
    update!(downloads: downloads + 1)
    if user.present?
      Users::ActivityService.new(user).create(UserActivity::ACTIVITY_TYPE_RESOURCE_DOWNLOAD, 'resource_id' => id)
    end
  end

  after_create :notify_on_slack

  def notify_on_slack
    return unless Rails.env.production?

    Resources::AfterCreateNotificationJob.perform_later(self)
  end

  before_save do
    # Ensure titles are capitalized.
    self.title = title.titlecase(humanize: false, underscore: false)
  end

  after_commit do
    # If the file attribute has changed, store its content_type to avoid lookup from S3.
    if previous_changes.key?(:file_as)
      update!(file_content_type: reload.file_as.content_type)
    end
  end
end
