class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :event_type, :event_on, :startup_id, :iteration

  TYPE_LAUNCH = 'launch'
  TYPE_AWARD = 'award'
  TYPE_TEAM_SIZE = 'team_size'
  TYPE_TEAM_FORMATION = 'team_formation'
  TYPE_SHOWCASE = 'showcase'
  TYPE_MISSION = 'mission'
  TYPE_SERIES_A = 'series_a'
  TYPE_SEED = 'seed_fund'
  TYPE_RELOCATE = 'relocate'
  TYPE_END_ITERATION = 'end_iteration'
  TYPE_PIVOT = 'pivot'
  TYPE_PATENT = 'patent'
  TYPE_REVENUE = 'revenue'
  TYPE_MENTOR = 'mentor'
  TYPE_N_CUSTOMERS = 'n_customers'
  TYPE_INVESTOR = 'investor'
  TYPE_INCORPORATED = 'incorporated'
  TYPE_INCUBATED = 'incubated'
  TYPE_GRADUATED = 'graduated'
  TYPE_ONE_CUSTOMER = 'one_customer'
  TYPE_DEBT_FUND = 'debt_fund'
  TYPE_CROWD_FUND = 'crowd_fund'
  TYPE_CO_FOUNDER = 'co_founder'
  TYPE_BANK = 'bank'
  TYPE_ATTENDED = 'attended'
  TYPE_ANGEL_FUND = 'angel_fund'
  TYPE_ACQUIRED = 'acquired'
  TYPE_ACCELERATOR = 'accelerator'
  TYPE_PROTOTYPE = 'prototype'

  def self.valid_event_types
    [
      TYPE_LAUNCH, TYPE_AWARD, TYPE_TEAM_SIZE, TYPE_TEAM_FORMATION, TYPE_SHOWCASE, TYPE_MISSION, TYPE_SERIES_A,
      TYPE_SEED, TYPE_RELOCATE, TYPE_END_ITERATION, TYPE_PIVOT, TYPE_PATENT, TYPE_REVENUE, TYPE_MENTOR,
      TYPE_N_CUSTOMERS, TYPE_INVESTOR, TYPE_INCORPORATED, TYPE_INCUBATED, TYPE_GRADUATED, TYPE_ONE_CUSTOMER,
      TYPE_DEBT_FUND, TYPE_CROWD_FUND, TYPE_CO_FOUNDER, TYPE_BANK, TYPE_ATTENDED, TYPE_ANGEL_FUND, TYPE_ACQUIRED,
      TYPE_ACCELERATOR, TYPE_PROTOTYPE
    ]
  end

  validates_inclusion_of :event_type, in: valid_event_types

  before_save :make_links_an_array

  def make_links_an_array
    self.links = [] if links.nil?
  end
end
