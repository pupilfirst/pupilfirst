class TopicSubscription < ApplicationRecord
  belongs_to :topics
  belongs_to :user
end
