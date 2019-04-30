class Comment < ApplicationRecord
  COMMENTABLE_TYPE_QUESTION = -'Question'
  COMMENTABLE_TYPE_ANSWER = -'Answer'

  VALID_COMMENTABLE_TYPES = [COMMENTABLE_TYPE_QUESTION, COMMENTABLE_TYPE_ANSWER].freeze

  belongs_to :commentable, polymorphic: true
  belongs_to :user
end
