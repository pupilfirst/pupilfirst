class Channel < ApplicationRecord
  belongs_to :school
  has_many :questions, dependent: :restrict_with_error
end
