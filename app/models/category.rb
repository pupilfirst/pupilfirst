class Category < ActiveRecord::Base
  scope :startup_category, -> { where category_type: 'startup' }
  scope :user_category, -> { where category_type: 'user' }

  has_and_belongs_to_many :startups
  has_and_belongs_to_many :users

  TYPES = %w(startup user) unless defined?(TYPES)

  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    startups.clear
  end
end
