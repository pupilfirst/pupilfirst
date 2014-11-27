class Category < ActiveRecord::Base
  scope :event_category, -> { where category_type: 'event' }
  scope :news_category, -> { where category_type: 'news' }
  scope :startup_category, -> { where category_type: 'startup' }
  scope :user_category, -> { where category_type: 'user' }
  scope :mentor_skill_category, -> { where category_type: 'mentor_skill' }

  has_many :news
  has_many :events
  has_and_belongs_to_many :startups, join_table: 'startups_categories'
  has_and_belongs_to_many :users
  has_many :mentor_skills, foreign_key: 'skill_id'
  has_many :mentors, through: :mentor_skills

  TYPES = %w(event news startup user mentor_skill) unless defined?(TYPES)

  def self.editor_categories
    %w(news event)
  end

  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    startups.clear
    mentor_skills.clear
  end
end
