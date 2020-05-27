# frozen_string_literal: true

class ConnectRequest < ApplicationRecord
  MAX_QUESTIONS_LENGTH = 600

  belongs_to :connect_slot
  belongs_to :startup

  scope :upcoming, -> { joins(:connect_slot).where('connect_slots.slot_at > ?', Time.now) }
  scope :completed, -> { joins(:connect_slot).where(status: STATUS_CONFIRMED).where('connect_slots.slot_at < ?', (Time.now - 20.minutes)) }
  scope :for_faculty, ->(faculty) { joins(:connect_slot).where(connect_slots: { faculty_id: faculty }) }
  scope :requested, -> { where(status: STATUS_REQUESTED) }
  scope :confirmed, -> { where(status: STATUS_CONFIRMED) }
  scope :cancelled, -> { where(status: STATUS_CANCELLED) }

  delegate :faculty, :slot_at, to: :connect_slot

  STATUS_REQUESTED = 'requested'
  STATUS_CONFIRMED = 'confirmed'
  STATUS_CANCELLED = 'cancelled'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_CONFIRMED, STATUS_CANCELLED]
  end

  validates :connect_slot_id, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :startup_id, presence: true
  validates :questions, presence: true, length: { maximum: MAX_QUESTIONS_LENGTH }
  validates :status, presence: true, inclusion: { in: valid_statuses }
  validates :rating_for_faculty, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true
  validates :rating_for_team, numericality: { greater_than: 0, less_than: 6 }, allow_nil: true

  before_validation :set_status_for_nil

  def set_status_for_nil
    self.status = STATUS_REQUESTED if status.nil?
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
end
