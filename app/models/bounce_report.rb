class BounceReport < ApplicationRecord
  validates :email, presence: true, email: true
end
