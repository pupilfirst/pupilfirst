class Startup < ActiveRecord::Base
  MAX_PITCH_CHARS = 140      unless defined?(MAX_PITCH_CHARS)
  MAX_ABOUT_WORDS = 500     unless defined?(MAX_ABOUT_WORDS)

  has_many :founders, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ?", true)}, :class_name => "User", :foreign_key => "startup_id"
  has_many :directors, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ? AND is_director = ?", true, true)}, :class_name => "User", :foreign_key => "startup_id"
	has_many :employees, -> { where("startup_link_verifier_id IS NOT NULL")}, :class_name => "User", :foreign_key => "startup_id"
	has_and_belongs_to_many :categories, :join_table => "startups_categories"
  has_one :bank
  serialize :company_names, JSON
  serialize :police_station, JSON
  validate :valid_categories?
  validate :valid_founders?
  validates_presence_of :name
  validates_presence_of :logo
  validates_presence_of :address
  validates_presence_of :email
  validates_presence_of :phone
  validates_length_of :pitch, :maximum => MAX_PITCH_CHARS, :message => "must be within #{MAX_PITCH_CHARS} characters", allow_nil: false
  validates_length_of :about, :within => 10..MAX_ABOUT_WORDS, :message => "must be within 10 to #{MAX_ABOUT_WORDS} words", tokenizer: ->(str) { str.scan(/\w+/) }, allow_nil: false

	def valid_categories?
   self.errors.add(:categories, "cannot have more than 3 categories") if categories.size > 3
   self.errors.add(:categories, "must have atleast one category") if categories.size < 1
	end

  def valid_founders?
   self.errors.add(:founders, "should have atleast one founder") if founders.nil? or founders.size < 1
  end

  mount_uploader :logo, AvatarUploader
  accepts_nested_attributes_for :founders
  normalize_attribute :name, :pitch, :about, :email, :phone

  normalize_attribute :twitter_link do |value|
    value = "http://#{value}" if value =~ /^twitter\.com.*/
    value = "http://twitter.com/#{value}"  unless value =~ /[http:\/\/]*twitter\.com.*/
    value if value =~ /^http[s]*:\/\/twitter\.com.*/
  end

  normalize_attribute :facebook_link do |value|
    value = "http://#{value}" if value =~ /^facebook\.com.*/
    value = "http://facebook.com/#{value}"  unless value =~ /[http:\/\/]*facebook\.com.*/
    value if value =~ /^http[s]*:\/\/facebook\.com.*/
  end

  def incorporation_submited?
    return true if company_names.present?
    false
  end

  def bank_details_submited?
    return true if self.bank
    false
  end

  def sep_submited?
    false
  end

  def incorporation_message
    return nil if incorporation_status
    return nil unless incorporation_submited?
    "message"
  end

  def banking_message
    return nil if bank_status
    return nil unless bank_details_submited?
    "message"
  end
end
