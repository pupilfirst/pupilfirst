class StartupJob < ActiveRecord::Base
  belongs_to :startup
  validates :title, presence: true
  validates :salary_min, presence: true
  validates_presence_of :equity_min, :if => :equity_max
  validates_presence_of :equity_max, :if => :equity_min
  validates_presence_of :equity_cliff, :equity_vest, :if => :equity_min
  validates :description, length: {maximum: 50}
end
