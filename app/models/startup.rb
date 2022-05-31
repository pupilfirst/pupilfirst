# frozen_string_literal: true

class Startup < ApplicationRecord
  acts_as_taggable

  scope :admitted, -> { joins(:level).where('levels.number > ?', 0) }
  scope :inactive,
        -> {
          where('access_ends_at < ?', Time.now).or(
            where.not(dropped_out_at: nil)
          )
        }
  scope :not_dropped_out, -> { where(dropped_out_at: nil) }
  scope :access_active,
        -> {
          where('access_ends_at > ?', Time.now).or(where(access_ends_at: nil))
        }
  scope :active, -> { not_dropped_out.access_active }

  belongs_to :level

  has_many :founders, dependent: :restrict_with_error
  has_many :faculty_startup_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_startup_enrollments
  has_one :course, through: :level
  has_one :school, through: :course

  validates :name, presence: true

  validate :not_assigned_to_level_zero

  def not_assigned_to_level_zero
    unless level.number.positive?
      errors.add(:level, 'cannot be assigned to level zero')
    end
  end

  def display_name
    name
  end

  def timeline_events
    TimelineEvent
      .joins(:timeline_event_owners)
      .where(timeline_event_owners: { founder: founders })
  end
end
