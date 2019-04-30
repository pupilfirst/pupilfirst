class Question < ApplicationRecord
  belongs_to :community
  belongs_to :user
  belongs_to :target, optional: true
  has_many :answers, dependent: :restrict_with_error
  has_many :comments, as: :commentable, dependent: :restrict_with_error
  has_one :school, through: :community
end
