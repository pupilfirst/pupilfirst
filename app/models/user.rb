class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable
	has_many :news, :class_name => "News", :foreign_key => "user_id"
	has_many :events
  mount_uploader :avatar, AvatarUploader
	process_in_background :avatar

end
