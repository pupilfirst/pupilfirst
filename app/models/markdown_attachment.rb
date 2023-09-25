class MarkdownAttachment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :school

  has_secure_token
  has_one_attached :file

  validates :file, attached: true
  validates :token, presence: true
  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :user_id,
                 time_frame: 1.day

  def image?
    file.content_type.in?(%w[image/png image/jpg image/jpeg image/gif])
  end
end
