class ProgramWeek < ApplicationRecord
  has_many :target_groups
  belongs_to :batch

  validates_presence_of :name, :number
  validates_uniqueness_of :number, scope: [:batch_id]

  def start_date
    return nil unless batch&.start_date.present?

    batch.start_date + ((number - 1) * 7).days
  end
end
