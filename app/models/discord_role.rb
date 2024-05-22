class DiscordRole < ApplicationRecord
  belongs_to :school
  has_and_belongs_to_many :users
end
