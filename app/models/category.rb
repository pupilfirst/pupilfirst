class Category < ActiveRecord::Base
  scope :event_category,        -> { where(category_type: 'event') }
  scope :news_category,         -> { where(category_type: 'news') }
  scope :startup_category,      -> { where(category_type: 'startup') }
  scope :startup_village_help,  -> { where(category_type: 'startup_village_help') }
  scope :contact_category,      -> { where(category_type: 'contact') }

  has_many :news
  has_many :events
  has_and_belongs_to_many :startups, join_table: 'startups_categories'
  has_and_belongs_to_many :contacts

  TYPES = %w(event news startup startup_village_help contact) unless defined?(TYPES)

  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    contacts.clear
    startups.clear
  end
end
