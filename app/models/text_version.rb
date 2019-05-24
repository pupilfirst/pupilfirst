class TextVersion < ApplicationRecord
  VERSIONABLE_TYPE__QUESTION = -'Question'
  VERSIONABLE_TYPE__ANSWER = -'Answer'

  VERSIONABLE_TYPE__TYPES = [VERSIONABLE_TYPE__QUESTION, VERSIONABLE_TYPE__ANSWER].freeze

  belongs_to :versionable, polymorphic: true
  belongs_to :user
end
