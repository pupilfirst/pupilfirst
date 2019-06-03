class AnswerLike < ApplicationRecord
  belongs_to :user
  belongs_to :answer

  validates :answer_id, uniqueness: { scope: :user_id }
end
