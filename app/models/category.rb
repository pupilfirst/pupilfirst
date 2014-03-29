class Category < ActiveRecord::Base

	scope :event_category, -> { where(category_type: 'event') }
	scope :news_category, -> { where(category_type: 'news') }
  scope :startup_category, -> { where(category_type: 'startup') }
	scope :startup_village_help, -> { where(category_type: 'startup_village_help') }

	has_many :news
	has_many :events
	has_and_belongs_to_many :startups, :join_table => "startups_categories"
	TYPES = ['event', 'news', 'startup', 'startup_village_help'] unless defined?(TYPES)
end
