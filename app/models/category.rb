class Category < ActiveRecord::Base
  has_and_belongs_to_many :startups
  has_and_belongs_to_many :users
  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    startups.clear
  end
end
