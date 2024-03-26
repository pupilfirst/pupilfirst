class CommunityCourseConnection < ApplicationRecord
  belongs_to :community
  belongs_to :course

  validates_with RateLimitValidator, limit: 50, scope: :community_id
end
