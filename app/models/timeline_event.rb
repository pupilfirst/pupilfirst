class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :event_type, :event_on, :startup_id, :iteration
  attr_accessor :link_url, :link_title

  TYPE_TEAM_FORMATION = 'team_formation'
  TYPE_PROSPECTIVE_CUSTOMER = 'prospective_customer'
  TYPE_IDEA = 'idea'
  TYPE_INCUBATED = 'incubated'
  TYPE_ACCELERATOR = 'accelerator'

  TYPE_MENTOR = 'mentor'
  TYPE_PATENT = 'patent'
  TYPE_TECH_STACK = 'tech_stack'
  TYPE_PROTOTYPE = 'prototype'
  TYPE_SEED = 'seed_fund'

  TYPE_LAUNCH = 'launch'
  TYPE_KEY_EMPLOYEE = 'key_employee'
  TYPE_CO_FOUNDER = 'co_founder'
  TYPE_KEY_TEAM_MEMBER_LEAVES = 'key_team_member_leaves'
  TYPE_CO_FOUNDER_LEAVES = 'co_founder_leaves'

  TYPE_USER_GROWTH = 'user_growth'
  TYPE_PIVOT = 'pivot'
  TYPE_FIRST_PAYING_CUSTOMER = 'first_paying_customer'
  TYPE_ANGEL_FUND = 'angel_funding'
  TYPE_SERIES_A = 'series_a'

  TYPE_MASSIVE_CUSTOMER_GROWTH = 'massive_customer_growth'
  TYPE_TECH_SCALING = 'tech_scaling'
  TYPE_END_ITERATION = 'end_iteration'
  TYPE_INCORPORATED = 'incorporated'
  TYPE_ACQUIRED = 'acquired'

  TYPE_ATTENDED = 'attended'
  TYPE_REVENUE = 'revenue'
  TYPE_DEBT_FUND = 'debt_fund'
  TYPE_RELOCATE = 'relocate'
  TYPE_SHOWCASE = 'showcase'

  TYPE_AWARD = 'award'
  TYPE_MISSION = 'mission'
  TYPE_TEAM_SIZE = 'team_size'
  TYPE_CROWD_FUND = 'crowd_fund'
  TYPE_BANK_LOAN = 'bank_loan'

  TYPE_GRADUATED = 'graduated'

  def self.valid_event_types
    [
      TYPE_TEAM_FORMATION, TYPE_PROSPECTIVE_CUSTOMER, TYPE_IDEA, TYPE_INCUBATED, TYPE_ACCELERATOR,
      TYPE_MENTOR, TYPE_PATENT, TYPE_TECH_STACK, TYPE_PROTOTYPE, TYPE_SEED,
      TYPE_LAUNCH, TYPE_KEY_EMPLOYEE, TYPE_CO_FOUNDER, TYPE_KEY_TEAM_MEMBER_LEAVES, TYPE_CO_FOUNDER_LEAVES,
      TYPE_USER_GROWTH, TYPE_PIVOT, TYPE_FIRST_PAYING_CUSTOMER, TYPE_ANGEL_FUND, TYPE_SERIES_A,
      TYPE_MASSIVE_CUSTOMER_GROWTH, TYPE_TECH_SCALING, TYPE_END_ITERATION, TYPE_INCORPORATED, TYPE_ACQUIRED,
      TYPE_ATTENDED, TYPE_REVENUE, TYPE_DEBT_FUND, TYPE_RELOCATE, TYPE_SHOWCASE,
      TYPE_AWARD, TYPE_MISSION, TYPE_TEAM_SIZE, TYPE_CROWD_FUND, TYPE_BANK_LOAN,
      TYPE_GRADUATED
    ]
  end

  validates_inclusion_of :event_type, in: valid_event_types
  validate :link_url_format

  LINK_URL_MATCHER = /(?:https?\/\/)?(?:www\.)?(?<domain>[\w-]+)\./

  def link_url_format
    if link_url.present? && link_url !~ LINK_URL_MATCHER
      self.errors.add(:link_url, 'does not look like a valid URL')
    end
  end


  before_save :make_links_an_array, :build_link_json
  before_validation :build_title_from_type, :record_iteration

  def build_title_from_type
    self.title = event_type.gsub('_',' ').capitalize
  end

  def record_iteration
    self.iteration = self.startup.current_iteration
  end

  def build_link_json
    if @link_url.present?
      title = LINK_URL_MATCHER.match(@link_url)[:domain]
      self.links = [{title: title, url: link_url}]
    end
  end

  def make_links_an_array
    self.links = [] if links.nil?
  end

  def verified?
    verified_at.present?
  end

  scope :verified, -> { where.not(verified_at: nil) }
end
