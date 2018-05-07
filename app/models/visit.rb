class Visit < ApplicationRecord
  has_many :ahoy_events, class_name: 'Ahoy::Event', dependent: :destroy
  belongs_to :user, polymorphic: true, optional: true
  belongs_to :logged_in_user, -> { where(visits: { user_type: 'User' }) }, class_name: 'User', foreign_key: 'user_id', optional: true, inverse_of: :visits

  scope :user_visits, -> { joins(:logged_in_user) }
  scope :last_week, -> { where('started_at > ?', 1.week.ago.beginning_of_day) }

  EVENT_VOCALIST_COMMAND = -'Vocalist Command'

  VOCALIST_COMMAND_LEADERBOARD = -'leaderboard'
  VOCALIST_COMMAND_CHANGELOG = -'changelog'
  VOCALIST_COMMAND_TARGETS = -'targets'
end
