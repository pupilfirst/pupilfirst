class ProgramWeek < ApplicationRecord
  validates_presence_of :name, :number
  # validates_uniqueness_of :number, scope: :batch_id
end
