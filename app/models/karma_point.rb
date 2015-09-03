class KarmaPoint < ActiveRecord::Base
  belongs_to :user
  delegate :startup, to: :user
end
