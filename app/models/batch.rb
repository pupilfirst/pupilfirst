class Batch < ActiveRecord::Base
  has_many :startups

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }

  validates :name, presence: true, uniqueness: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates_presence_of :start_date, :end_date
  validates :slack_channel, format: { with: /#[^A-Z\s.;!?]+/, message: "must start with a # and not contain uppercase, spaces or periods" },
                            length: { in: 2..22, message: "channel name should be 1-21 characters" }, allow_nil: true

  def to_label
    "##{batch_number} #{name}"
  end

  # TODO: Batch.current should probably be re-written to account for overlapping batches.
  def self.current
    where('start_date <= ? and end_date >= ?', Time.now, Time.now).first
  end

  # If the current batch isn't present, supply last.
  def self.current_or_last
    current.present? ? current : last
  end
end
