# encoding: utf-8
# frozen_string_literal: true

class Faculty < ActiveRecord::Base
  # use name as slug
  include FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  validates_format_of :slug, with: /\A[a-z0-9\-_]+\z/i, allow_nil: true

  mount_uploader :image, FacultyImageUploader
  process_in_background :image

  has_secure_token

  has_many :startup_feedback, dependent: :restrict_with_error
  has_many :targets, dependent: :restrict_with_error, foreign_key: 'assigner_id'
  has_many :connect_slots, dependent: :destroy
  has_many :connect_requests, through: :connect_slots

  # link alumni faculty to their founder profile
  belongs_to :founder
  validates_presence_of :founder, message: 'Must link alumni to their faculty profile', if: :alumni?

  def alumni?
    category == CATEGORY_ALUMNI
  end

  CATEGORY_TEAM = -'team'
  CATEGORY_VISITING_FACULTY = -'visiting_faculty'
  CATEGORY_ADVISORY_BOARD = -'advisory_board'
  CATEGORY_ALUMNI = -'alumni'

  validates_presence_of :name, :title, :category, :image

  def self.valid_categories
    [CATEGORY_TEAM, CATEGORY_VISITING_FACULTY, CATEGORY_ADVISORY_BOARD, CATEGORY_ALUMNI]
  end

  validates_inclusion_of :category, in: valid_categories

  scope :active, -> { where.not(inactive: true) }
  scope :team, -> { where(category: CATEGORY_TEAM).order('sort_index ASC') }
  scope :visiting_faculty, -> { where(category: CATEGORY_VISITING_FACULTY).order('sort_index ASC') }
  scope :advisory_board, -> { where(category: CATEGORY_ADVISORY_BOARD).order('sort_index ASC') }
  scope :alumni, -> { where(category: CATEGORY_ALUMNI).order('sort_index ASC') }
  scope :available_for_connect, -> { where(category: [CATEGORY_TEAM, CATEGORY_VISITING_FACULTY, CATEGORY_ALUMNI]) }

  # This method sets the label used for object by Active Admin.
  def display_name
    name
  end

  # copy slots from the last available week to the next week
  def copy_weekly_slots!
    return unless last_available_connect_date

    days_to_offset = days_since_last_available_week
    return if days_to_offset <= 0 # return if there is/are slot(s) for next week or later

    slots_to_copy = last_available_weekly_slots

    slots_to_copy.each do |slot|
      connect_slots.create!(slot_at: slot.slot_at + days_to_offset)
    end
  end

  def last_available_connect_date
    connect_slots.order('slot_at DESC').first.try(:slot_at)
  end

  def last_available_weekly_slots
    connect_slots.where(slot_at: (last_available_connect_date.beginning_of_week..last_available_connect_date.end_of_week))
  end

  # number of days to offset when creating next week slots (from last available weekly slots)
  def days_since_last_available_week
    (7.days.from_now.beginning_of_week.to_date - last_available_connect_date.beginning_of_week.to_date).to_i.days
  end

  def past_connect_sessions(limit = nil)
    ConnectRequest.for_faculty(self).completed.limit(limit).order('connect_slots.slot_at DESC')
  end

  def average_rating
    ratings_received = past_connect_sessions.pluck(:rating_of_faculty).compact
    return nil unless ratings_received
    ratings_received.inject { |a, e| a + e }.to_f / ratings_received.size
  end
end
