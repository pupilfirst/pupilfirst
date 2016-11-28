class ProgramWeek < ApplicationRecord
  has_many :target_groups

  validates_presence_of :name, :number
  # validates_uniqueness_of :number, scope: :batch_id
end
