class SchoolAdmin < ApplicationRecord
  belongs_to :user
  delegate :school, :name, :email, :title, to: :user
  
  validates_with RateLimitValidator, limit: 100, scope: :school_id
end
