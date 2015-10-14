class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_many :targets, dependent: :restrict_with_error, foreign_key: 'assigner_id'

  TYPE_SUPERADMIN = 'superadmin'
  TYPE_TIMELINE_REVIEWER = 'timeline_reviewer'

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar
  normalize_attribute :password, :password_confirmation, :fullname, :avatar

  def self.admin_user_types
    [TYPE_SUPERADMIN, TYPE_TIMELINE_REVIEWER]
  end

  validates :admin_type, inclusion: { in: admin_user_types }, allow_nil: true

  def display_name
    email
  end
end
