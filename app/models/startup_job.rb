class StartupJob < ActiveRecord::Base
  EXPIRY_DURATION = 60.days

  belongs_to :startup

  validates :title, presence: true
  validates :salary_min, presence: true
  validates_presence_of :equity_min, if: :equity_max
  validates_presence_of :equity_max, if: :equity_min
  validates_presence_of :equity_cliff, :equity_vest, if: :equity_min
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
