class DiscordRole < ApplicationRecord
  belongs_to :school
  has_and_belongs_to_many :users,
                          dependent: :destroy,
                          join_table: "additional_user_discord_roles"
end
