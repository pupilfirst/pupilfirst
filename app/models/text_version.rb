class TextVersion < ApplicationRecord
  belongs_to :versionable, polymorphic: true
  belongs_to :user
end
