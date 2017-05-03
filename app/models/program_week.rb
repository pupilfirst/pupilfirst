class ProgramWeek < ApplicationRecord
  has_many :target_groups
  has_many :targets, through: :target_groups
  belongs_to :batch

  validates :name, presence: true
  validates :number, presence: true, uniqueness: { scope: [:batch_id] }

  def display_name
    "W#{number}: #{name}"
  end

  def start_date
    return nil if batch&.start_date.blank?
    batch.start_date + ((number - 1) * 7).days
  end
end
