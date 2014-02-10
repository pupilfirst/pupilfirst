class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable
	has_many :news, :class_name => "News", :foreign_key => "user_id"
	has_many :events
	belongs_to :startup

  validates_uniqueness_of :username
  mount_uploader :avatar, AvatarUploader
	process_in_background :avatar
  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? value.downcase == 'true' : value
  end

  normalize_attribute :twitter_url do |value|
    value = "http://#{value}" if value =~ /^twitter\.com.*/
    value = "http://twitter.com/#{value}"  unless value =~ /[http:\/\/]*twitter\.com.*/
    value if value =~ /^http[s]*:\/\/twitter\.com.*/
  end

  normalize_attribute :linkedin_url do |value|
    value = "http://#{value}" if value =~ /^linkedin\.com.*/
    value = "http://linkedin.com/in/#{value}"  unless value =~ /[http:\/\/]*linkedin\.com.*/
    value if value =~ /^http[s]*:\/\/linkedin\.com.*/
  end

	def to_s
		fullname or username
	end
end
