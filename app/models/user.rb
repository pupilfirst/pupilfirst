class User < ActiveRecord::Base
	has_many :news, :class_name => "News", :foreign_key => "user_id"
	has_many :events
  mount_uploader :avatar, AvatarUploader
	process_in_background :avatar

end
