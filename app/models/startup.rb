class Startup < ActiveRecord::Base
  MAX_PITCH_CHARS = 140      unless defined?(MAX_PITCH_CHARS)
  MAX_ABOUT_WORDS = 500     unless defined?(MAX_ABOUT_WORDS)
  scope :valid, -> { where(approval_status: true) }

  has_many :founders, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ?", true)}, class_name: "User", foreign_key: "startup_id" do
    def <<(founder)
      founder.update_attributes!(is_founder: true, startup_link_verifier_id: founder.id)
      super founder
    end
  end

  has_many :directors, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ? AND is_director = ?", true, true)}, :class_name => "User", :foreign_key => "startup_id" do |*args|
    def <<(director)
      director.update_attributes!(startup_link_verifier_id: director.id, is_founder: true, is_director: true)
      super director
    end
  end

  has_many :employees, -> { where("startup_link_verifier_id IS NOT NULL")}, :class_name => "User", :foreign_key => "startup_id"
  has_and_belongs_to_many :categories, :join_table => "startups_categories"
  has_one :bank
  belongs_to :registered_address, class_name: 'Address'
  serialize :company_names, JSON
  serialize :startup_before, JSON
  serialize :police_station, JSON
  serialize :help_from_sv, Array
  validate :valid_categories?
  validate :valid_founders?
  validates_associated :founders
  validates_length_of :help_from_sv, minimum: 1, too_short: 'must select atleast one', if: ->(startup){@full_validation }

  validates_presence_of :name, if: ->(startup){@full_validation }
  validates_presence_of :address, if: ->(startup){@full_validation }
  validates_presence_of :email
  validates_presence_of :phone
  validates_presence_of :pre_funds, if: ->(startup){startup.pre_investers_name.present?}
  validates_presence_of :pre_investers_name, if: ->(startup){startup.pre_funds.present?}
  validates_length_of :pitch, maximum: MAX_PITCH_CHARS, message: "must be within #{MAX_PITCH_CHARS} characters", allow_nil: false, if: ->(startup){@full_validation }
  validates_length_of :about, {
    within: 10..MAX_ABOUT_WORDS, message: "must be within 10 to #{MAX_ABOUT_WORDS} words",
    tokenizer: ->(str) { str.scan(/\w+/) }, allow_nil: false,
    if: ->(startup){@full_validation }
  }

  def valid_help_from_sv?
    self.errors.add(:help_from_sv, "must select at least one") if help_from_sv.empty?
    true
  end

  def valid_categories?
   return true unless @full_validation
   self.errors.add(:categories, "can't have more than 3 categories") if categories.size > 3
   self.errors.add(:categories, "must select at least one category") if categories.size < 1
  end

  def valid_founders?
   self.errors.add(:founders, "should have at least one founder") if founders.nil? or founders.size < 1
  end

  mount_uploader :logo, AvatarUploader
  process_in_background :logo
  accepts_nested_attributes_for :founders, :registered_address
  normalize_attribute :name, :pitch, :about, :email, :phone
  attr_accessor :full_validation

  after_initialize ->(){
    @full_validation = true
  }

  normalize_attribute :help_from_sv do |value|
    value.select { |e| e.present? }.map { |e| e.to_i }
  end

  normalize_attribute :website do |value|
    case value
    when '' then nil
    when nil then nil
    when /^http:\/\/.*/ then value
    else "http://#{value}"
    end
  end

  normalize_attribute :twitter_link do |value|
    case value
    when /^http[s]*:\/\/twitter\.com.*/ then value
    when /^twitter\.com.*/ then "http://#{value}"
    when "" then nil
    when nil then nil
    else "http://twitter.com/#{value}"
    end
  end

  normalize_attribute :facebook_link do |value|
    case value
    when /^http[s]*:\/\/facebook\.com.*/ then value
    when /^facebook\.com.*/ then "http://#{value}"
    when "" then nil
    when nil then nil
    else "http://facebook.com/#{value}"
    end
  end

  def founder_ids=(list_of_ids)
    users_list = User.find list_of_ids.map{ |e| e.to_i }.select{ |e|  e.is_a?(Integer) and e > 0 }
    users_list.each{|u| founders << u }
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

  def is_bank_transaction_field_enabled?
    return false if transaction_details.present?
    return true if directors.all? { |d| d.personal_info_submitted? }
  end

  def incorporation_message
    return nil if incorporation_status?
    return nil unless incorporation_submited?
    return I18n.t("startup_village.messages.incorporate.documents_required",
                  documents_submition_date: DbConfig.documents_submition_date,
                  documents_submition_time: DbConfig.documents_submition_time) if incorporation_submited? and transaction_details.present?
    return I18n.t("startup_village.messages.incorporate.pending_payment",
                  full_amount: amount_to_be_paid_for_incorporation) if directors.all? { |d| d.personal_info_submitted? }
    pending_directors = directors.reject { |d| d.personal_info_submitted? }
    pending_directors_msg = pending_directors.map { |d| "Pending: #{d.fullname}" }.join("\n")
    I18n.t("startup_village.messages.incorporate.pending_director_info", pending_directors_msg: pending_directors_msg)
  end

  def banking_message
    return nil if bank_status
    return nil unless bank_details_submited?
    "message"
  end

  def amount_to_be_paid_for_incorporation
    num_pans = directors.reject{|d| d.pan.present? }.count
    num_dins = directors.reject{|d| d.din.present? }.count
    18225 + num_pans*105 + num_dins*400 + 105
  end
end
