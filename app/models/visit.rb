class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  belongs_to :user, polymorphic: true
  belongs_to :founder, -> { where(visits: { user_type: 'Founder' }) }, foreign_key: 'user_id'

  scope :founder_visits, -> { joins(:founder) }
  scope :last_week, -> { where('started_at > ?', 1.week.ago.beginning_of_day) }
end
