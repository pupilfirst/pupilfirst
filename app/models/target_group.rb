class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :program_week
  has_one :batch, through: :program_week

  validates_presence_of :name, :description, :number
  validates_uniqueness_of :number, scope: [:program_week_id]
end
