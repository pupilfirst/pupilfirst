# frozen_string_literal: true

class Resource < ApplicationRecord
  include FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]
  acts_as_taggable

  belongs_to :school
  has_many :target_resources, dependent: :destroy
  has_many :targets, through: :target_resources
  has_one_attached :file

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
    return if [file.attached?, video_embed.present?, link.present?].one?
    return if persisted?

    errors[:base] << 'One and only one of a video embed, file or link must be present.'
  end

  scope :public_resources, -> { where(public: true).order('title') }

  # Custom scope to allow AA to filter by intersection of tags.
  scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }

  scope :live, -> { where(archived: [false, nil]) }

  def self.ransackable_scopes(_auth)
    %i[ransack_tagged_with]
  end

  def stream?
    return false if link.present?
    return true if video_embed.present?

    if file.attached?
      file.content_type.end_with?('/mp4')
    else
      false
    end
  end

  def increment_downloads(user)
    update!(downloads: downloads + 1)
    if user.present?
      Users::ActivityService.new(user).create(UserActivity::ACTIVITY_TYPE_RESOURCE_DOWNLOAD, 'resource_id' => id)
    end
  end

  before_save do
    # Ensure titles are capitalized.
    self.title = title.titlecase(humanize: false, underscore: false)
  end
end
