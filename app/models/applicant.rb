class Applicant < ApplicationRecord
  belongs_to :course

  acts_as_taggable

  validates :name, presence: true
  validates :email,
            presence: true,
            email: true,
            uniqueness: {
              scope: :course_id
            }

  scope :verified, -> { where(email_verified: true) }
  scope :with_email, ->(email) { where("lower(email) = ?", email.downcase) }

  validates_with RateLimitValidator,
                 limit: 10_000,
                 scope: :course_id,
                 time_frame: 1.day

  def regenerate_login_token
    @original_login_token = SecureRandom.urlsafe_base64
    update!(
      login_token_digest: Digest::SHA2.base64digest(@original_login_token)
    )
  end

  def original_login_token
    @original_login_token || raise("Original login token is unavailable")
  end
end
