class Startup < ActiveRecord::Base
  REGISTRATION_TYPE_PRIVATE_LIMITED = 'private_limited'
  REGISTRATION_TYPE_PARTNERSHIP = 'partnership'
  REGISTRATION_TYPE_LLP = 'llp' # Limited Liability Partnership

  MAX_PITCH_CHARACTERS = 140 unless defined?(MAX_PITCH_CHARACTERS)
  MAX_ABOUT_CHARACTERS = 1000 unless defined?(MAX_ABOUT_CHARACTERS)
  MAX_CATEGORY_COUNT = 3

  APPROVAL_STATUS_UNREADY = 'unready'
  APPROVAL_STATUS_PENDING = 'pending'
  APPROVAL_STATUS_APPROVED = 'approved'
  APPROVAL_STATUS_REJECTED = 'rejected'

  PRODUCT_PROGRESS_IDEA = 'idea'
  PRODUCT_PROGRESS_MOCKUP = 'mockup'
  PRODUCT_PROGRESS_PROTOTYPE = 'prototype'
  PRODUCT_PROGRESS_PRIVATE_BETA = 'private_beta'
  PRODUCT_PROGRESS_PUBLIC_BETA = 'public_beta'
  PRODUCT_PROGRESS_LAUNCHED = 'launched'

  INCUBATION_LOCATION_KOCHI = 'kochi'
  INCUBATION_LOCATION_VISAKHAPATNAM = 'visakhapatnam'

  def self.valid_incubation_location_values
    [INCUBATION_LOCATION_KOCHI, INCUBATION_LOCATION_VISAKHAPATNAM]
  end

  def self.valid_product_progress_values
    [PRODUCT_PROGRESS_IDEA, PRODUCT_PROGRESS_MOCKUP, PRODUCT_PROGRESS_PROTOTYPE, PRODUCT_PROGRESS_PRIVATE_BETA, PRODUCT_PROGRESS_PUBLIC_BETA, PRODUCT_PROGRESS_LAUNCHED]
  end

  def self.valid_registration_types
    [REGISTRATION_TYPE_PRIVATE_LIMITED, REGISTRATION_TYPE_PARTNERSHIP, REGISTRATION_TYPE_LLP]
  end

  def self.valid_approval_status_values
    [APPROVAL_STATUS_UNREADY, APPROVAL_STATUS_PENDING, APPROVAL_STATUS_APPROVED, APPROVAL_STATUS_REJECTED]
  end

  has_paper_trail

  scope :approved, -> { where(approval_status: APPROVAL_STATUS_APPROVED) }

  has_many :founders, -> { where("startup_link_verifier_id IS NOT NULL AND is_founder = ?", true) }, class_name: "User", foreign_key: "startup_id" do
    def <<(founder)
      founder.update_attributes!(is_founder: true, startup_link_verifier_id: founder.id)
      super founder
    end
  end

  has_many :employees, -> { where("startup_link_verifier_id IS NOT NULL") }, :class_name => "User", :foreign_key => "startup_id"

  has_and_belongs_to_many :categories, :join_table => 'startups_categories' do
    def <<(category)
      raise StandardError, 'Use categories= to enforce startup category limit'
    end
  end

  has_one :bank
  belongs_to :registered_address, class_name: 'Address'
  has_many :partnerships

  serialize :company_names, JSON
  serialize :startup_before, JSON
  serialize :police_station, JSON
  serialize :help_from_sv, Array

  validate :valid_founders?
  validates_associated :founders
  # validates_length_of :help_from_sv, minimum: 1, too_short: 'must select atleast one', if: ->(startup){@full_validation }

  # Registration type should be one of Pvt. Ltd., Partnership, or LLC.
  validates :registration_type,
    inclusion: { in: valid_registration_types },
    allow_nil: true

  # Product Progress should be one of acceptable list.
  validates :product_progress,
    inclusion: { in: valid_product_progress_values },
    allow_nil: true,
    allow_blank: true

  # Product Progress should be one of acceptable list.
  validates :incubation_location,
    inclusion: { in: valid_incubation_location_values },
    allow_nil: true

  # validates_presence_of :name, if: ->(startup){@full_validation }
  # validates_presence_of :address, if: ->(startup){@full_validation }
  # validates_presence_of :email
  # validates_presence_of :phone

  validates_presence_of :pre_funds, if: ->(startup) { startup.pre_investers_name.present? }
  validates_presence_of :pre_investers_name, if: ->(startup) { startup.pre_funds.present? }

  validates_length_of :pitch, maximum: MAX_PITCH_CHARACTERS,
    message: "must be within #{MAX_PITCH_CHARACTERS} characters",
    allow_nil: true, if: ->(startup) { @full_validation }

  validates_length_of :about, maximum: MAX_ABOUT_CHARACTERS,
    message: "must be within #{MAX_ABOUT_CHARACTERS} characters",
    allow_nil: true, if: ->(startup) { @full_validation }

  before_validation do
    # Set registration_type to nil if its set as blank from backend.
    self.registration_type = nil if self.registration_type.blank?

    # Hack to fix incorrect registration_type sent by iOS build 2.0.
    self.registration_type = REGISTRATION_TYPE_PRIVATE_LIMITED if self.registration_type == 'pvt. ltd.'
  end

  before_destroy do
    # Clear out associations from associated Users (and pending ones).
    User.where(startup_id: self.id).update_all(startup_id: nil)
    User.where(pending_startup_id: self.id).update_all(pending_startup_id: nil)
  end

  nilify_blanks only: [:revenue_generated, :team_size, :women_employees, :approval_status, :product_progress]

  def admin
    founders.where(startup_admin: true).first
  end

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

  def valid_founders?
    self.errors.add(:founders, "should have at least one founder") if founders.nil? or founders.size < 1
  end

  mount_uploader :logo, AvatarUploader
  process_in_background :logo
  accepts_nested_attributes_for :founders, :registered_address
  normalize_attribute :name, :pitch, :about, :email, :phone
  attr_accessor :full_validation

  after_initialize ->() {
    @full_validation = true
  }

  normalize_attribute :help_from_sv do |value|
    value.select { |e| e.present? }.map { |e| e.to_i }
  end

  normalize_attribute :website do |value|
    case value
      when '' then
        nil
      when nil then
        nil
      when /^https?:\/\/.*/ then
        value
      else
        "http://#{value}"
    end
  end

  normalize_attribute :twitter_link do |value|
    case value
      when /^https?:\/\/(www\.)?twitter.com.*/ then
        value
      when /^(www\.)?twitter\.com.*/ then
        "https://#{value}"
      when '' then
        nil
      when nil then
        nil
      else
        "https://twitter.com/#{value}"
    end
  end

  normalize_attribute :facebook_link do |value|
    case value
      when /^https?:\/\/(www\.)?facebook.com.*/ then
        value
      when /^(www\.)?facebook\.com.*/ then
        "https://#{value}"
      when '' then
        nil
      when nil then
        nil
      else
        "https://facebook.com/#{value}"
    end
  end

  def founder_ids=(list_of_ids)
    users_list = User.find list_of_ids.map { |e| e.to_i }.select { |e| e.is_a?(Integer) and e > 0 }
    users_list.each { |u| founders << u }
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

  validate :category_count

  def category_count
    if @category_count_exceeded || self.categories.count > MAX_CATEGORY_COUNT
      self.errors.add(:categories, "Can't have more than 3 categories")
    end
  end

  # Custom setter for startup categories.
  #
  # @param [String, Array] category_entries Array of Categories or comma-separated Category ID-s.
  def categories=(category_entries)
    parsed_categories = if category_entries.is_a? String
      category_entries.split(',').map do |category_id|
        Category.find(category_id)
      end
    else
      category_entries
    end

    # Enforce maximum count for categories.
    if parsed_categories.count > MAX_CATEGORY_COUNT
      @category_count_exceeded = true
    else
      super parsed_categories
    end
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

  # TODO: Remove incorporation_status boolean field.
end
