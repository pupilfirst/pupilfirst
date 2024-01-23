class ModerationReport < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true
end
