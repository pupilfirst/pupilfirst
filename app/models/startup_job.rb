class StartupJob < ActiveRecord::Base
  EXPIRY_DURATION = 1.month

  belongs_to :startup

  validates_presence_of :title, :salary_min, :location
  validates_length_of :location, maximum: 50
  validates_length_of :description, maximum: 500, allow_nil: true 
  validates_presence_of :equity_min, if: :equity_max 
  validates_presence_of :equity_max, if: :equity_min
  validates_presence_of :equity_vest, if: :equity_min || :equity_cliff
  validates_presence_of :equity_cliff, if: :equity_min || :equity_vest
  
  validate :equity_min_less_than_max
  
  def equity_min_less_than_max
    if self.equity_min && self.equity_max
      if self.equity_min >= self.equity_max
        errors.add :equity_min, 'must be less than maximum equity.'
        errors.add :equity_max, 'must be greater than minimum equity.'
      end
    end
  end

  validate :equity_vest_less_than_cliff

  def equity_vest_less_than_cliff
    if self.equity_vest && self.equity_cliff
      if self.equity_vest >= self.equity_cliff
        errors.add :equity_vest, 'must be less than equity cliff'
        errors.add :equity_cliff, 'must be greater than equity vest'
      end
    end  
  end

  validate :salary_min_less_than_max

  def salary_min_less_than_max
    if self.salary_max && self.salary_min
      if self.salary_min >= self.salary_max
        errors.add :salary_min, 'must be less than maximum salary'
        errors.add :salary_max, 'must be greater than minimum salary'
      end
    end
  end

  scope :not_expired, -> { where('expires_on > ?', Time.now) }

  def reset_expiry!
    self.expires_on = EXPIRY_DURATION.from_now
  end

  before_create do
    reset_expiry!
  end

  def expired?
    Time.now > self.expires_on
  end

  def can_be_modified_by?(user)
    return false unless user

    startup.is_founder?(user)
  end
end
