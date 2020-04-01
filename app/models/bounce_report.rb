class BounceReport < ApplicationRecord
  validates :email, presence: true, email: true
  validates :bounce_type, presence: true
end
