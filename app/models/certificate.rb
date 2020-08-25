class Certificate < ApplicationRecord
  belongs_to :course

  has_many :issued_certificates, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :includes_image, -> { includes(image_attachment: :blob) }

  has_one_attached :image

  def image_path
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end
end
