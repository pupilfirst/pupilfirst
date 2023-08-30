class Quiz < ApplicationRecord
  belongs_to :target
  has_many :quiz_questions, dependent: :restrict_with_error
  has_many :answer_options, through: :quiz_questions

  validates :title, presence: true

  validates_with RateLimitValidator, limit: 5, scope: :target_id
end
