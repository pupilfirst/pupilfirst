class Category < ActiveRecord::Base

	scope :event_category, -> { where(category_type: 'event') }
	scope :news_category, -> { where(category_type: 'news') }

	has_many :news
	has_many :events

	TYPES = ['events', 'news']
end
