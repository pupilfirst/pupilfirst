class Milestone < ApplicationRecord
  has_many :targets, dependent: :restrict_with_error
end
