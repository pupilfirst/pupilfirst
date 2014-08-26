class Startup < ActiveRecord::Base
  REGISTRATION_TYPE_PRIVATE_LIMITED = 'private_limited'
  REGISTRATION_TYPE_PARTNERSHIP = 'partnership'

  MAX_PITCH_CHARS = 140      unless defined?(MAX_PITCH_CHARS)
  MAX_ABOUT_WORDS = 500     unless defined?(MAX_ABOUT_WORDS)

  APPROVAL_STATUS_UNREADY = 'unready'
  APPROVAL_STATUS_PENDING = 'pending'
  APPROVAL_STATUS_APPROVED = 'approved'
  APPROVAL_STATUS_REJECTED = 'rejected'

  def self.valid_registration_types
    [REGISTRATION_TYPE_PRIVATE_LIMITED, REGISTRATION_TYPE_PARTNERSHIP]
  end

  has_paper_trail

  scope :approved, -> { where(approval_status: APPROVAL_STATUS_APPROVED) }

  has_many :founders, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ?", true)}, class_name: "User", foreign_key: "startup_id" do
    def <<(founder)
      founder.update_attributes!(is_founder: true, startup_link_verifier_id: founder.id)
      super founder
    end
  end

  has_many :employees, -> { where("startup_link_verifier_id IS NOT NULL")}, :class_name => "User", :foreign_key => "startup_id"
  has_and_belongs_to_many :categories, :join_table => "startups_categories"
  has_one :bank
  belongs_to :registered_address, class_name: 'Address'
  has_many :partnerships

  serialize :company_names, JSON
  serialize :startup_before, JSON
  serialize :police_station, JSON
  serialize :help_from_sv, Array
  # validate :valid_categories?
  validate :valid_founders?
  validates_associated :founders
  # validates_length_of :help_from_sv, minimum: 1, too_short: 'must select atleast one', if: ->(startup){@full_validation }

  # Registration type should be one of Pvt. Ltd., or a Partnership.
  validates :registration_type,
    inclusion: { in: valid_registration_types },
    allow_nil: true

  # validates_presence_of :name, if: ->(startup){@full_validation }
  # validates_presence_of :address, if: ->(startup){@full_validation }
  # validates_presence_of :email
  # validates_presence_of :phone

  validates_presence_of :pre_funds, if: ->(startup){startup.pre_investers_name.present?}
  validates_presence_of :pre_investers_name, if: ->(startup){startup.pre_funds.present?}

  validates_length_of :pitch, maximum: MAX_PITCH_CHARS,
    message: "must be within #{MAX_PITCH_CHARS} characters",
    allow_nil: true, if: ->(startup){@full_validation }

  validates_length_of :about, {
    within: 10..MAX_ABOUT_WORDS, message: "must be within 10 to #{MAX_ABOUT_WORDS} words",
    tokenizer: ->(str) { str.scan(/\w+/) }, allow_nil: true,
    if: ->(startup){@full_validation }
  }

  def approval_status
    super || APPROVAL_STATUS_UNREADY
  end

  def approved?
    approval_status == APPROVAL_STATUS_APPROVED
  end

  def pending?
    approval_status == APPROVAL_STATUS_PENDING
  end

  def unready?
    approval_status == APPROVAL_STATUS_UNREADY
  end

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

  # Custom setter for startup categories.
  #
  # @param [String, Array] category_entries Array of Categories or comma-separated Category ID-s.
  def categories=(category_entries)
    unless category_entries.is_a? String
      super(category_entries)
      return
    end

    category_table_entries = category_entries.split(',').map do |category_id|
      Category.find(category_id)
    end

    super category_table_entries
  end

  def register(registration_params)
    update_startup_parameters(registration_params)
    create_or_update_partnerships(registration_params[:partners])
  end

  def update_startup_parameters(startup_params)
    self.update_attributes(startup_params.slice(:registration_type, :address, :state, :district, :pitch, :total_shares))
  end

  def create_or_update_partnerships(partners_params)
    partners_params.each do |partner_params|
      user = User.find_or_initialize_by(email: partner_params[:email])
      user.fullname = partner_params[:fullname]
      user.save_unregistered_user!

      partnership_params = partner_params.slice(:shares, :cash_contribution, :salary, :managing_director, :operate_bank_account).merge(user: user)
      partnerships.create!(partnership_params)
    end
  end
end
