class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :program_week
  has_one :batch, through: :program_week

  validates :name, presence: true
  validates :description, presence: true
  validates :sort_index, presence: true, uniqueness: { scope: [:program_week_id] }
end
