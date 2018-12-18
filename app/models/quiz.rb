class Quiz < ApplicationRecord
  belongs_to :target
  has_many :quiz_questions, dependent: :restrict_with_error

  validates :title, presence: true
end
