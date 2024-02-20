class Certificate < ApplicationRecord
  belongs_to :course

  has_many :issued_certificates, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :includes_image, -> { includes(image_attachment: :blob) }

  has_one_attached :image

  validates_with RateLimitValidator, limit: 100, scope: :course_id

  def image_path
    Rails.application.routes.url_helpers.rails_public_blob_url(image)
  end
end
