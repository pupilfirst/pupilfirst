class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  has_many :news, class_name: "News", foreign_key: :user_id
  has_many :events
  has_many :social_ids
  belongs_to :bank
  belongs_to :father, class_name: 'Name'
  belongs_to :address
  belongs_to :guardian
  belongs_to :startup
  belongs_to :startup_link_verifier, class_name: "User", foreign_key: "startup_link_verifier_id"
  scope :non_founders, -> { where("startup_id IS NULL") }
  accepts_nested_attributes_for :social_ids, :father, :address, :guardian

  attr_reader :skip_password
  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar
  normalize_attribute :startup_id
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

  before_create do
    self.auth_token = SecureRandom.hex(30)
    self.startup_verifier_token = SecureRandom.hex(30)
  end

  class << self
    def find_by_social_record(network, social_id)
      social_record = SocialId.find_by_provider_and_social_id(network.to_s, social_id.to_s)
      return nil if social_record.nil?
      social_record.user
    end
  end

  def verify(user)
    return false if user.startup.nil?
    raise "#{fullname} not allowed to verify founders yet" if startup_link_verifier.nil?
    raise "#{fullname} not allowed to verify founders of #{user.startup.name}" if startup != user.startup
    user.update_attributes!(startup_link_verifier: self)
  end

  def verify_self!
    update_attributes!(startup_link_verifier: self)
  end

  def confirm_employee!(is_founder)
    self.update_attributes!(startup_link_verifier_id: self.id, is_founder: is_founder)
    push_message = 'Hola! you have been accepted.'
    UserPushNotifyJob.new.async.perform(self.id, :employee_confirmed, push_message)
  end

  def verified?
    return true if startup_link_verifier
  end

  def approved?
    return true if startup.approval_status and verified?
  end

  def profile_info_submitted?
    return true if self.father
    false
  end

  def profile_info_enabled?
    return true if is_founder and not profile_info_submitted?
    false
  end

  def incorporation_enabled?
    return false if startup.incorporation_status?
    return true if is_founder
    false
  end

  def bank_details_enabled?
    return false if startup.bank_status?
    return true if is_founder and startup.incorporation_submited?
    false
  end

  def sep_enabled?
    true
  end

  def to_s
    fullname
  end
end
