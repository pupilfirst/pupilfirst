class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :reactionable, polymorphic: true
end
