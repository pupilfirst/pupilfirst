class Question < ApplicationRecord
  belongs_to :channel
  belongs_to :user
  belongs_to :target, optional: true
  has_many :answers, dependent: :restrict_with_error
end
