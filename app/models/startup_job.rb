class StartupJob < ActiveRecord::Base
  EXPIRY_DURATION = 1.month

  belongs_to :startup

  validates_presence_of :title, :location, :contact_name, :contact_email, :description
  validates_length_of :location, :title, maximum: 50
  validates_length_of :description, maximum: 500
  validates_presence_of :equity_min, if: :equity_max
  validates_presence_of :equity_min, :equity_vest, if: :equity_cliff
  validates_presence_of :equity_min, :equity_cliff, if: :equity_vest
  validates_numericality_of :equity_min, greater_than_or_equal_to: 0, allow_nil: true
  validates_numericality_of :equity_max, greater_than_or_equal_to: 0, allow_nil: true
  validates_numericality_of :equity_vest, greater_than_or_equal_to: 0, allow_nil: true
  validates_numericality_of :equity_cliff, greater_than_or_equal_to: 0, allow_nil: true

  validate :equity_min_less_than_max

  def equity_min_less_than_max
    return unless equity_min && equity_max
    return unless equity_min >= equity_max
    errors.add :equity_min, 'must be less than maximum equity.'
    errors.add :equity_max, 'must be greater than minimum equity.'
  end

  validate :equity_vest_greater_than_cliff

  def equity_vest_greater_than_cliff
    return unless equity_vest && equity_cliff
    return unless equity_vest < equity_cliff
    errors.add :equity_vest, 'must be greater than equity cliff'
    errors.add :equity_cliff, 'must be less than equity vest'
  end

  scope :not_expired, -> { where('expires_on > ?', Time.now) }

  def reset_expiry!
    self.expires_on = EXPIRY_DURATION.from_now
  end

  before_create do
    reset_expiry! if expires_on.nil?
  end

  def expired?
    Time.now > expires_on
  end

  def can_be_modified_by?(user)
    return false unless user
    startup.founder?(user)
  end

  def equity_summary
    summary = ''
    summary = 'min: ' + equity_min.to_s if equity_min?
    summary += ' | max: ' + equity_max.to_s if equity_max?
    summary += ' | vest: ' + equity_vest.to_s if equity_vest?
    summary += ' | cliff: ' + equity_cliff.to_s if equity_cliff?
    summary
  end
end
