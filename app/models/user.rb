class User < ActiveRecord::Base
  has_one :mooc_student, dependent: :restrict_with_error
  belongs_to :university

  has_secure_token :login_token
  after_create :regenerate_login_token

  validates :email, presence: true, uniqueness: true, format: { with: /@/, message: 'does not look like a valid address' }
  validates :university_id, presence: true
  validates :phone, format: { with: /\A[0-9]{10}\z/, message: 'should be a 10-digit number' }
end
