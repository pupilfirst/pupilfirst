# encoding: utf-8
# frozen_string_literal: true

class ConnectRequest < ApplicationRecord
  MEETING_DURATION = 20.minutes
  MAX_QUESTIONS_LENGTH = 600

  belongs_to :connect_slot
  belongs_to :startup

  has_one :karma_point, as: :source

  scope :upcoming, -> { joins(:connect_slot).where('connect_slots.slot_at > ?', Time.now) }
  scope :completed, -> { joins(:connect_slot).where(status: STATUS_CONFIRMED).where('connect_slots.slot_at < ?', (Time.now - 20.minutes)) }
  scope :for_faculty, ->(faculty) { joins(:connect_slot).where(connect_slots: { faculty_id: faculty }) }

  delegate :faculty, :slot_at, to: :connect_slot

  STATUS_REQUESTED = 'requested'
  STATUS_CONFIRMED = 'confirmed'
  STATUS_CANCELLED = 'cancelled'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_CONFIRMED, STATUS_CANCELLED]
  end

  validates :connect_slot_id, presence: true, uniqueness: true
  validates :startup_id, presence: true
  validates :questions, presence: true, length: { maximum: MAX_QUESTIONS_LENGTH }
  validates :status, presence: true, inclusion: { in: valid_statuses }
  validates :rating_for_faculty, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true
  validates :rating_for_team, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true

  before_validation :set_status_for_nil

  def set_status_for_nil
    self.status = STATUS_REQUESTED if status.nil?
  end

  def time_for_feedback_mail?
    (connect_slot.slot_at + 40.minutes).past? ? true : false
  end

  def feedback_mails_sent?
    feedback_mails_sent_at.present?
  end

  def feedback_mails_sent!
    update!(feedback_mails_sent_at: Time.now)
  end

  def requested?
    status == STATUS_REQUESTED
  end

  def confirmed?
    status == STATUS_CONFIRMED
  end

  def cancelled?
    status == STATUS_CANCELLED
  end

  scope :requested, -> { where(status: STATUS_REQUESTED) }
  scope :confirmed, -> { where(status: STATUS_CONFIRMED) }
  scope :cancelled, -> { where(status: STATUS_CANCELLED) }

  def assign_karma_points(rating)
    rating = rating.to_i
    return false if rating < 3

    if KarmaPoint.find_by(source: self).blank?
      KarmaPoints::CreateService.new(self, points_for_rating(rating)).execute
    end
  end

  private

  def points_for_rating(rating)
    {
      3 => 10,
      4 => 20,
      5 => 40
    }[rating]
  end
end
