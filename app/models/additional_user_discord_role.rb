class AdditionalUserDiscordRole < ApplicationRecord
  belongs_to :user
  belongs_to :discord_role
end
