class AdditionalUserDiscordRole < ApplicationRecord
  acts_as_copy_target

  belongs_to :user
  belongs_to :discord_role
end
