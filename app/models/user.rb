class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable
	has_many :news, :class_name => "News", :foreign_key => "user_id"
	has_many :events
	belongs_to :startup

  mount_uploader :avatar, AvatarUploader
	process_in_background :avatar
  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? value.downcase == 'true' : value
  end

	def to_s
		username
	end
end
