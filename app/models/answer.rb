class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  has_many :answer_claps, dependent: :restrict_with_error
  has_many :comments, as: :commentable, dependent: :restrict_with_error
end
