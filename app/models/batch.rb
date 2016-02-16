class Batch < ActiveRecord::Base
  has_many :startups

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }

  validates :name, presence: true, uniqueness: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates_presence_of :start_date, :end_date

  def to_label
    "##{batch_number} #{name}"
  end

  # TODO: Batch.current should probably be re-written to account for overlapping batches.
  def self.current
    where('start_date <= ? and end_date >= ?', Time.now, Time.now).first
  end
end
