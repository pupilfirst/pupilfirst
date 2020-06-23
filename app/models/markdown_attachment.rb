class MarkdownAttachment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :school

  has_secure_token
  has_one_attached :file

  validates :file, attached: true
  validates :token, presence: true

  def image?
    file.content_type.in?(%w[image/png image/jpg image/jpeg image/gif])
  end
end
