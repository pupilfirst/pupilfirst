class Resource < ActiveRecord::Base
  include FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  belongs_to :batch

  def slug_candidates
    [:title, [:title, :updated_at]]
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  SHARE_STATUS_PUBLIC = 'public'
  SHARE_STATUS_APPROVED = 'approved'

  def self.valid_share_statuses
    [SHARE_STATUS_PUBLIC, SHARE_STATUS_APPROVED]
  end

  validates_presence_of :file, :title, :description, :share_status
  validates_inclusion_of :share_status, in: valid_share_statuses

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader

  scope :public_resources, -> { where(share_status: SHARE_STATUS_PUBLIC).order('title') }

  delegate :content_type, to: :file

  def self.for(user)
    if user.present? && user.founder?
      where(
        'share_status = ? OR (share_status = ? AND batch_id IS ?) OR (share_status = ? AND batch_id = ?)',
        SHARE_STATUS_PUBLIC,
        SHARE_STATUS_APPROVED,
        nil,
        SHARE_STATUS_APPROVED,
        user.startup&.batch&.id
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
end
