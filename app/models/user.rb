class User < ActiveRecord::Base
  GENDER_MALE = 'male'
  GENDER_FEMALE = 'female'
  GENDER_OTHER = 'other'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  has_many :news, class_name: "News", foreign_key: :user_id
  has_many :events
  has_many :social_ids
  has_one :student_entrepreneur_policy
  belongs_to :bank
  belongs_to :father, class_name: 'Name'
  belongs_to :address
  belongs_to :guardian
  belongs_to :startup
  belongs_to :startup_link_verifier, class_name: "User", foreign_key: "startup_link_verifier_id"
  scope :non_employees, -> { where("startup_id IS NULL") }
  scope :non_founders, -> { where("is_founder = ? or is_founder IS NULL", false) }
  accepts_nested_attributes_for :social_ids, :father, :address, :guardian

  # TODO: Remove born_on, title, and salutation columns if unneccessary.
  # validates_presence_of :born_on
  # validates_presence_of :title, if: ->(user){ user.full_validation }
  # validates_presence_of :salutation, message: ''

  # We don't have a full name when we're creating a temporary co-founder account.
  validates_presence_of :fullname, unless: ->(user) { user.pending_startup_id.present? }

  validates :gender, inclusion: { in: [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER] }, allow_nil: true

  attr_reader :skip_password
  # hack
  attr_accessor :inviter_name
  attr_accessor :accept_startup
  attr_accessor :full_validation
  after_initialize ->() {
    @full_validation = false
  }

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar
  normalize_attribute :startup_id, :title
  normalize_attribute :skip_password do |value|
    value.is_a?(String) ? value.downcase == 'true' : value
  end

  normalize_attribute :twitter_url do |value|
    value = "http://#{value}" if value =~ /^twitter\.com.*/
    value = "http://twitter.com/#{value}" unless value =~ /[http:\/\/]*twitter\.com.*/
    value if value =~ /^http[s]*:\/\/twitter\.com.*/
  end

  normalize_attribute :linkedin_url do |value|
    value = "http://#{value}" if value =~ /^linkedin\.com.*/
    value = "http://linkedin.com/in/#{value}" unless value =~ /[http:\/\/]*linkedin\.com.*/
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
  end

  def verified?
    return true if startup_link_verifier
  end

  def approved_message
    return nil if startup.try(:approval_status) and verified?
    return I18n.t('startup_village.messages.startup_approval.link_startup', company_name: startup.try(:name)) unless verified?
    I18n.t('startup_village.messages.startup_approval.from_startup_village', company_name: startup.try(:name))
  end

  def personal_info_submitted?
    return true if self.father
    false
  end

  def personal_info_enabled?
    return false if startup.try(:incorporation_status?)
    return false unless is_founder
    true
  end

  def incorporation_enabled?
    return false if startup.try(:incorporation_status?)
    return true if is_founder and personal_info_submitted?
    false
  end

  def bank_details_enabled?
    return false if startup.try(:bank_status?)
    return true if is_founder and startup.try(:incorporation_submited?) and personal_info_submitted?
    false
  end

  def personal_info_message
    return I18n.t("startup_village.messages.personal_info.incorporation_done",
      documents_submition_date: DbConfig.documents_submition_date,
      documents_submition_time: DbConfig.documents_submition_time) if personal_info_submitted? and is_director
    return I18n.t("startup_village.messages.personal_info.no_incorporation") if personal_info_submitted?
  end

  def sep_enabled?
    is_student?
  end
  #
  # def gender
  #   if salutation == 'Mr'
  #     :male
  #   else
  #     :female
  #   end
  # end

  def to_s
    fullname or email
  end

  def self.find_or_initialize_cofounder(email)
    cofounder = find_or_initialize_by(email: email)

    raise Exceptions::UserAlreadyMemberOfStartup, 'User already belongs to a startup, and cannot be added again.' if cofounder.startup

    cofounder
  end

  def save_cofounder
    # Devise wants a random password.
    self.password = SecureRandom.hex

    save
  end
end
