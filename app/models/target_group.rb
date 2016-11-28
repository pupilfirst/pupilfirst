class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :program_week

  validates_presence_of :name, :description
end
