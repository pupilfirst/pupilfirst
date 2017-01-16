class ProgramWeek < ApplicationRecord
  has_many :target_groups
  has_many :targets, through: :target_groups
  belongs_to :batch

  validates :name, presence: true
  validates :number, presence: true, uniqueness: { scope: [:batch_id] }
  validates :icon_name, presence: true

  def display_name
    "W#{number}: #{name}"
  end

  def start_date
    return nil unless batch&.start_date.present?

    batch.start_date + ((number - 1) * 7).days
  end

  def self.icon_name_options
    path = File.absolute_path(Rails.root.join('app', 'assets', 'images', 'founders', 'dashboard', 'program-week-icons'))
    Dir.entries(path).select { |f| !File.directory? f }
  end
end
