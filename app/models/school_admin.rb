class SchoolAdmin < ApplicationRecord
  belongs_to :user
  belongs_to :school

  delegate :name, :email, :title, to: :user

  validates_with RateLimitValidator, limit: 100, scope: :school_id
end
