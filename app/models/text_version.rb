class TextVersion < ApplicationRecord
  belongs_to :versionable, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :editor, class_name: 'User', optional: true
end
