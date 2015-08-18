class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  belongs_to :timeline_event_type
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
    {
      TYPE_TEAM_FORMATION => 'Team Formed',
      TYPE_PROSPECTIVE_CUSTOMER => 'Found Prospective Customer',
      TYPE_IDEA => 'Had a great Idea',
      TYPE_INCUBATED => 'Incubated at Startup Village',
      TYPE_ACCELERATOR => 'Joined an Accelerator',
      TYPE_MENTOR => 'Found a Mentor',
      TYPE_PATENT => 'Patent Granted',
      TYPE_TECH_STACK => 'Decided on Tech Stack',
      TYPE_PROTOTYPE => 'Demo-ed Prototype',
      TYPE_SEED => 'Received Seed Funding',
      TYPE_LAUNCH => 'Launched Product',
      TYPE_KEY_EMPLOYEE => 'Key Employee Joined',
      TYPE_CO_FOUNDER => 'Co-founder Joined',
      TYPE_KEY_TEAM_MEMBER_LEAVES => 'Team Member left',
      TYPE_CO_FOUNDER_LEAVES => 'Co-founder left',
      TYPE_USER_GROWTH => 'User counts increased',
      TYPE_PIVOT => 'Pivoted',
      TYPE_FIRST_PAYING_CUSTOMER => 'Sold to First Customer',
      TYPE_ANGEL_FUND => 'Received Angel Funding',
      TYPE_SERIES_A => 'Raised Series A Funding',
      TYPE_MASSIVE_CUSTOMER_GROWTH => 'Massive Customer Growth',
      TYPE_TECH_SCALING =>  'Improved Scalability across Stack',
      TYPE_END_ITERATION => 'End of current Iteration',
      TYPE_INCORPORATED => 'Incorporated Company',
      TYPE_ACQUIRED => 'Acquired by another Company',
      TYPE_ATTENDED => 'Attended an event',
      TYPE_REVENUE => 'Revenue threshold crossed',
      TYPE_DEBT_FUND => 'Received Debt Funding',
      TYPE_RELOCATE => 'Team Relocated',
      TYPE_SHOWCASE => 'Showcased in media',
      TYPE_AWARD => 'Won an Award',
      TYPE_MISSION => 'Set new Mission',
      TYPE_TEAM_SIZE => 'Team size increased',
      TYPE_CROWD_FUND => 'Raised Crowd Funding',
      TYPE_BANK_LOAN => 'Received Bank Loan',
      TYPE_GRADUATED => 'Graduated from Startup Village'
    }
  end

  validate :link_url_format

  LINK_URL_MATCHER = /(?:https?\/\/)?(?:www\.)?(?<domain>[\w-]+)\./

  def link_url_format
    if link_url.present? && link_url !~ LINK_URL_MATCHER
      self.errors.add(:link_url, 'does not look like a valid URL')
    end
  end


  before_save :make_links_an_array, :build_link_json
  before_validation :build_default_title_from_type, :record_iteration

  def build_default_title_from_type
    unless title.present?
      self.title = self.timeline_event_type.title
    end
  end

  def record_iteration
    self.iteration = self.startup.current_iteration
  end

  def build_link_json
    if link_title.present? && link_url.present?
      self.links = [{title: link_title, url: link_url}]
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
