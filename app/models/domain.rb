class Domain < ApplicationRecord
  belongs_to :school

  validates_with RateLimitValidator, limit: 100, scope: :school_id

  def self.primary
    find_by(primary: true) || first
  end
end
