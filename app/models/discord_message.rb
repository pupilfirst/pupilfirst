class DiscordMessage < ApplicationRecord
  belongs_to :user
  has_one :school, through: :user
  validates :author_uuid, presence: true
  validates :message_uuid, presence: true
  validates :server_uuid, presence: true
end
