class WebhookEndpoint < ApplicationRecord
  belongs_to :course
  validates_with RateLimitValidator, limit: 25, scope: :course_id
end
