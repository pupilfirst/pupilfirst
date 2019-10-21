class Visit < ApplicationRecord
  has_many :ahoy_events, class_name: 'Ahoy::Event', dependent: :destroy
  belongs_to :user, polymorphic: true, optional: true

  scope :user_visits, -> { where(visits: { user_type: 'User' }) }
  scope :last_week, -> { where('started_at > ?', 1.week.ago.beginning_of_day) }

  EVENT_VOCALIST_COMMAND = -'Vocalist Command'

  VOCALIST_COMMAND_LEADERBOARD = -'leaderboard'
  VOCALIST_COMMAND_TARGETS = -'targets'
end
