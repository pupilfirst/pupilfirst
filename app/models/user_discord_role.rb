class UserDiscordRole < ApplicationRecord
  belongs_to :user
  belongs_to :discord_role
end
