class Category < ActiveRecord::Base
  scope :event_category,        -> { where category_type: 'event' }
  scope :news_category,         -> { where category_type: 'news' }
  scope :startup_category,      -> { where category_type: 'startup' }
  scope :user_category,         -> { where category_type: 'user' }

  has_many :news
  has_many :events
  has_and_belongs_to_many :startups, join_table: 'startups_categories'
  has_and_belongs_to_many :users

  TYPES = %w(event news startup user mentor_skill) unless defined?(TYPES)

  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    startups.clear
  end
end
