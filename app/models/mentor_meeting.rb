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
  STATUS_EXPIRED = 'expired'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_REJECTED, STATUS_ACCEPTED, STATUS_COMPLETED, STATUS_STARTED, STATUS_EXPIRED]
  end

  validates_inclusion_of :status, in: valid_statuses

  DURATION_QUARTER_HOUR = 15.minutes
  DURATION_HALF_HOUR = 30.minutes
  DURATION_HOUR = 1.hour

  def self.valid_durations
    [DURATION_QUARTER_HOUR, DURATION_HALF_HOUR, DURATION_HOUR]
  end

  validates_presence_of :duration
  validates_inclusion_of :duration, in: valid_durations

  validates_presence_of :purpose
  validates_presence_of :suggested_meeting_at

  validate :suggested_meeting_time_required

  def suggested_meeting_time_required
    # When creating a mentor meeting request, don't allow it to be done without specific time being selected.
    unless persisted?
      if @suggested_meeting_time.blank?
        errors.add(:suggested_meeting_time, 'cannot be blank')
      end
    end
  end

  validate :reject_with_comment

  def reject_with_comment
    if rejected? && mentor_comments.blank?
      errors[:base] << 'Mentor must write comment to reject meeting request'
    end
  end

  validate :accept_with_meeting_at

  def accept_with_meeting_at
    if accepted? && meeting_at.blank?
      errors[:base] << 'Meeting cannot be accepted without setting meeting_at'
    end
  end

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
        { hour: 9, min: 00 }
      when Mentor::AVAILABILITY_TIME_MIDDAY
        { hour: 12, min: 00 }
      when Mentor::AVAILABILITY_TIME_AFTERNOON
        { hour: 15, min: 00 }
      when Mentor::AVAILABILITY_TIME_EVENING
        { hour: 18, min: 00 }
      else
        nil
    end
  end

  def gave_feedback?(user)
    if user.is_a? Mentor
      mentor_rating.present?
    else
      user_rating.present?
    end
  end

  def did_not_give_feedback?(user)
    !gave_feedback?(user)
  end

  def start!
    update!(status: STATUS_STARTED)
  end

  def accept!(accepted_meeting_at)
    update!(status: STATUS_ACCEPTED, meeting_at: accepted_meeting_at)
    send_acceptance_message
  end

  def send_acceptance_message
    if rescheduled?
      UserMailer.meeting_request_rescheduled(self).deliver_now
    else
      UserMailer.meeting_request_accepted(self).deliver_now
    end
  end

  def reject!(mentor_comments_for_rejection)
    update!(status: STATUS_REJECTED, mentor_comments: mentor_comments_for_rejection)
    send_rejection_message
  end

  def send_rejection_message
    UserMailer.meeting_request_rejected(self).deliver_now
  end

  def complete!
    update!(status: STATUS_COMPLETED)
  end

  def rescheduled?
    meeting_at != suggested_meeting_at
  end

  def rejected?
    status == STATUS_REJECTED
  end

  def accepted?
    status == STATUS_ACCEPTED
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def starts_soon?
    accepted? && (meeting_at < 15.minutes.from_now)
  end
end
 