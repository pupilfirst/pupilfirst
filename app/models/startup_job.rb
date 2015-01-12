class StartupJob < ActiveRecord::Base
  EXPIRY_DURATION = 60.days

  belongs_to :startup

  validates :title, :salary_min, presence: true, if: :startup_id
  validates_numericality_of :salary_min, less_than: :salary_max, if: :salary_max
  validates_presence_of :equity_min, if: :equity_max 
  validates_presence_of :equity_max, if: :equity_min
  validates_numericality_of :equity_max, greater_than: :equity_min, if: :equity_min
  validates_presence_of :equity_cliff, if: :equity_vest && :equity_min
  validates_numericality_of :equity_cliff, greater_than: :equity_vest, if: :equity_vest
  validates_presence_of :equity_vest, if: :equity_cliff, less_than: :equity_cliff
  validates :description, length: { maximum: 500 }

  # TODO: Minimum values should not be greater than maximum values.

  def reset_expiry!
    self.expires_on = EXPIRY_DURATION.from_now
  end

  before_create do
    reset_expiry!
  end

  def expired?
    Time.now > self.expires_on
  end
end
