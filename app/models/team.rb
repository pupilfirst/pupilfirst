class Team < ApplicationRecord
  belongs_to :cohort
  has_many :founders, dependent: :restrict_with_error
end
