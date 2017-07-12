class Batch < ApplicationRecord
  has_many :startups
  has_many :founders, through: :startups

  scope :live, -> { where('start_date <= ? and end_date >= ?', Time.now, Time.now) }
  scope :not_completed, -> { where('end_date >= ?', Time.now) }

  validates :theme, presence: true
  validates :batch_number, presence: true, numericality: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :slack_channel, slack_channel_name: true, allow_nil: true

  def display_name
    "##{batch_number} #{theme}"
  end

  alias name display_name

  # TODO: Batch.current should probably be re-written to account for overlapping batches.
  def self.current
    find_by('start_date <= ? and end_date >= ?', Time.now, Time.now)
  end

  # If the current batch isn't present, supply last.
  def self.current_or_last
    current.present? ? current : last
  end

  def invites_sent?
    invites_sent_at.present?
  end

  # Return the week number for this batch.
  def present_week_number
    return nil unless start_date.beginning_of_day.past?
    return 1 if Date.today == start_date

    days_elapsed = (Date.today - start_date)
    weeks_elapsed = days_elapsed.to_f / 7

    # Let's round up.
    weeks_elapsed.ceil
  end
end
