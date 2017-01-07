class ApplicationRound < ApplicationRecord
  belongs_to :batch

  validates :batch, presence: true
  validates :number, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
end
