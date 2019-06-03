class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :creator, class_name: 'User'
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :archiver, class_name: 'User', optional: true

  scope :live, -> { where(archived: false) }
end
