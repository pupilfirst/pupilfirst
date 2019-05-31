class Comment < ApplicationRecord
  COMMENTABLE_TYPE_QUESTION = -'Question'
  COMMENTABLE_TYPE_ANSWER = -'Answer'

  VALID_COMMENTABLE_TYPES = [COMMENTABLE_TYPE_QUESTION, COMMENTABLE_TYPE_ANSWER].freeze

  belongs_to :commentable, polymorphic: true
  belongs_to :creator, class_name: 'User'
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :archiver, class_name: 'User', optional: true

  scope :live, -> { where(archived: false) }
end
