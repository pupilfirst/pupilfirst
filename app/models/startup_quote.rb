class StartupQuote < ApplicationRecord
  validates :guid, presence: true
  validates :link, presence: true
end
