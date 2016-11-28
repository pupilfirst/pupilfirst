class TargetGroup < ApplicationRecord
  has_many :targets

  validates_presence_of :name, :description
end
