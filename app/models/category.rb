class Category < ActiveRecord::Base
  scope :startup_category, -> { where category_type: 'startup' }
  scope :user_category, -> { where category_type: 'user' }
  scope :mentor_skill_category, -> { where category_type: 'mentor_skill' }

  has_and_belongs_to_many :startups
  has_and_belongs_to_many :users
  has_many :mentor_skills, foreign_key: 'skill_id'
  has_many :mentors, through: :mentor_skills

  TYPES = %w(startup user mentor_skill) unless defined?(TYPES)

  # Before a category is destroyed, make sure that entries in association tables are removed.
  before_destroy do
    startups.clear
    mentor_skills.clear
  end
end
