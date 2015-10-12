class Resource < ActiveRecord::Base
  SHARE_STATUS_PUBLIC = 'public'
  SHARE_STATUS_APPROVED = 'approved'

  def self.valid_share_statuses
    [SHARE_STATUS_PUBLIC, SHARE_STATUS_APPROVED]
  end

  validates_presence_of :file, :title, :description, :share_status
  validates_inclusion_of :share_status, in: valid_share_statuses
  validates_numericality_of :shared_with_batch, allow_blank: true

  normalize_attributes :shared_with_batch

  mount_uploader :file, ResourceFileUploader
  mount_uploader :thumbnail, ResourceThumbnailUploader

  scope :public_resources, -> { where(share_status: SHARE_STATUS_PUBLIC) }

  def self.for(user)
    if user.present? && user.founder?
      where(
        'share_status = ? OR (share_status = ? AND shared_with_batch IS ?) OR (share_status = ? AND shared_with_batch = ?)',
        SHARE_STATUS_PUBLIC,
        SHARE_STATUS_APPROVED,
        nil,
        SHARE_STATUS_APPROVED,
        user.startup.try(:batch)
      )
    else
      public_resources
    end
  end

  def for_approved?
    share_status == SHARE_STATUS_APPROVED
  end
end
