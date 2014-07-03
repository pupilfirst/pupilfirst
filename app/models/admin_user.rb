class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  TYPE_SUPERADMIN = 'superadmin'
  TYPE_EDITOR = 'editor'

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar
  normalize_attribute :password, :password_confirmation, :username, :fullname, :avatar

  def self.admin_user_types
    [TYPE_SUPERADMIN, TYPE_EDITOR]
  end

  validates :admin_type, inclusion: { in: admin_user_types }, allow_nil: true

  def to_s
    fullname or username
  end
end
