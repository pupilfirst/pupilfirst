class MentorMeeting < ActiveRecord::Base
  belongs_to :user
  belongs_to :mentor

  serialize :suggested_meeting_timings, JSON

  RATING_1 = 1 # Meeting was of no, or little use.
  RATING_2 = 2 # Some use.
  RATING_3 = 3 # Useful.
  RATING_4 = 4 # Really useful.
  RATING_5 = 5 # Absolutely incredible, eye-opening, etc.

  def self.valid_ratings
    [RATING_1, RATING_2, RATING_3, RATING_4, RATING_5]
  end

  validates_inclusion_of :mentor_rating, in: valid_ratings, allow_nil: true
  validates_inclusion_of :user_rating, in: valid_ratings, allow_nil: true

  STATUS_REQUESTED = 'requested'
  STATUS_REJECTED = 'rejected'
  STATUS_ACCEPTED = 'accepted'
  STATUS_STARTED = 'started'
  STATUS_COMPLETED = 'completed'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_REJECTED, STATUS_ACCEPTED, STATUS_COMPLETED, STATUS_STARTED]
  end

  validates_inclusion_of :status, in: valid_statuses

  DURATION_QUARTER_HOUR = 15.minutes
  DURATION_HALF_HOUR = 30.minutes
  DURATION_HOUR = 1.hour

  def self.valid_durations
    [DURATION_QUARTER_HOUR, DURATION_HALF_HOUR, DURATION_HOUR]
  end

  validates_inclusion_of :duration, in: valid_durations

  before_save do 
    if @suggested_meeting_time
      self.suggested_meeting_at = self.suggested_meeting_at.change @suggested_meeting_time
    end
  end
  
  def suggested_meeting_time
    nil
  end

  def suggested_meeting_time=(value)
    @suggested_meeting_time = case value
    when Mentor::AVAILABILITY_TIME_MORNING
      {hour: 3, min: 30}
    when Mentor::AVAILABILITY_TIME_MIDDAY
      {hour: 6, min: 30}
    when Mentor::AVAILABILITY_TIME_AFTERNOON
      {hour: 9, min: 30}
    when Mentor::AVAILABILITY_TIME_EVENING
      {hour: 12, min: 30}
    else
      nil
    end  
  end

  def mentor_rating?
    self.mentor_rating.present?
  end

  def user_rating?
    self.user_rating.present?
  end
end
 