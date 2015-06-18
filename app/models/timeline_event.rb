class TimelineEvent < ActiveRecord::Base
  belongs_to :startup
  mount_uploader :image, TimelineImageUploader
  serialize :links
  validates_presence_of :title, :type, :event_on, :startup_id, :iteration

  TYPE_LAUNCH = "Launch"
  TYPE_AWARD = "Award"
  TYPE_TEAM_SIZE = "TeamSize"
  TYPE_TEAM_FORM = "TeamForm"
  TYPE_SHOWCASE = "Showcase"
  TYPE_MISSION = "Mission"
  TYPE_SERIESA = "SeriesA"
  TYPE_SEED = "SeedFund"
  TYPE_LOCATION = "Relocate"
  TYPE_ITERATION = "NewIteration"
  TYPE_PIVOT = "Pivot"
  TYPE_PATENT = "Patent"
  TYPE_REVENUE = "Revenue"
  TYPE_MENTOR = "Mentor"
  TYPE_NCUSTOMERS = "NCustomers"
  TYPE_INVESTOR = "Investor"
  TYPE_INCORPORATED = "Incorporated"
  TYPE_INCUBATE = "Incubated"
  TYPE_GRADUATE = "Graduated"
  TYPE_1CUSTOMER = "1Customer"
  TYPE_DEBTFUND = "DebtFunding"
  TYPE_CROWDFUND = "CrowdFunding"
  TYPE_COFOUNDER = "Cofounder"
  TYPE_BANK = "Bank"
  TYPE_ATTENDED = "Attended"
  TYPE_ANGELFUND = "AngelFunding"
  TYPE_ACQUIRED = "Acquired"
  TYPE_ACCELERATER = "Accelerator"


  def self.valid_types
    [ TYPE_LAUNCH, TYPE_AWARD, TYPE_TEAM_SIZE ,TYPE_TEAM_FORM, TYPE_SHOWCASE, TYPE_MISSION, TYPE_SERIESA, \
 TYPE_SEED, TYPE_LOCATION, TYPE_ITERATION, TYPE_PIVOT, TYPE_PATENT, TYPE_REVENUE, TYPE_MENTOR, \
 TYPE_NCUSTOMERS, TYPE_INVESTOR, TYPE_INCORPORATED, TYPE_INCUBATE, TYPE_GRADUATE, TYPE_1CUSTOMER, \
 TYPE_DEBTFUND, TYPE_CROWDFUND, TYPE_COFOUNDER, TYPE_BANK, TYPE_ATTENDED, TYPE_ANGELFUND, TYPE_ACQUIRED, \
 TYPE_ACCELERATER ]
  end

  validates_inclusion_of :event_type, in: valid_types

  scope :belongs_to_iteration, ->(i) { where(:iteration => i)}
end
