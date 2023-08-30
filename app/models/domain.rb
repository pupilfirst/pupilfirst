class Domain < ApplicationRecord
  belongs_to :school

  validates_with RateLimitValidator, limit: 10, scope: :school_id

  def self.primary
    find_by(primary: true) || first
  end
end
