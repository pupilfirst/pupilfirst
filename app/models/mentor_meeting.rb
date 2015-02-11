class MentorMeeting < ActiveRecord::Base
  belongs_to :user
  belongs_to :mentor

  serialize :suggested_meeting_timings, JSON

  RATING_0 = 0 # Meeting was of no use.
  RATING_1 = 1 # Meeting was of little use.
  RATING_2 = 2 # Some use.
  RATING_3 = 3 # Useful.
  RATING_4 = 4 # Really useful.
  RATING_5 = 5 # Absolutely incredible, eye-opening, etc.

  def self.valid_ratings
    [RATING_0, RATING_1, RATING_2, RATING_3, RATING_4, RATING_5]
  end

  validates_inclusion_of :mentor_rating, in: valid_ratings, allow_nil: true
  validates_inclusion_of :user_rating, in: valid_ratings, allow_nil: true

  STATUS_REQUESTED = 'requested'
  STATUS_REJECTED = 'rejected'
  STATUS_RESCHEDULED = 'rescheduled'
  STATUS_ACCEPTED = 'accepted'
  STATUS_STARTED = 'started'
  STATUS_COMPLETED = 'completed'
  STATUS_EXPIRED = 'expired'

  def self.valid_statuses
    [STATUS_REQUESTED, STATUS_REJECTED, STATUS_ACCEPTED, STATUS_COMPLETED, STATUS_STARTED, STATUS_EXPIRED, STATUS_RESCHEDULED]
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

  # REWRITE FOR rejection by mentor and startup
  # validate :reject_with_comment

  # def reject_with_comment
  #   if rejected? && mentor_comments.blank?
  #     errors[:base] << 'Mentor must write comment to reject meeting request'
  #   end
  # end

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
    # TO BE CORRECTED
    # send_acceptance_message
  end

  def send_acceptance_message
    if rescheduled?
      UserMailer.meeting_request_rescheduled(self).deliver_now
    else
      UserMailer.meeting_request_accepted(self).deliver_now
    end
  end

  def reject!(mentor_meeting,role)
    if role == "mentor"
      update!(status: STATUS_REJECTED, mentor_comments: mentor_meeting["mentor_comments"])
    else
      update!(status: STATUS_REJECTED, user_comments: mentor_meeting["user_comments"])
    end
    # TO BE CORRECTED
    # send_rejection_message
  end

  def send_rejection_message
    UserMailer.meeting_request_rejected(self).deliver_now
  end

  def complete!
    update!(status: STATUS_COMPLETED)
  end

  def rescheduled?
    status == STATUS_RESCHEDULED
  end

  def requested?
    status == STATUS_REQUESTED
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

  def recent_sms_sent?(user)
    if is_mentor?(user)
      recent_mentor_sms?
    else
      recent_user_sms?
    end
  end

  def recent_user_sms?
    user_sms_sent_at.present? && user_sms_sent_at > 30.minutes.ago
  end

  def recent_mentor_sms?
    mentor_sms_sent_at.present? && mentor_sms_sent_at > 30.minutes.ago
  end

  def sent_sms(user)
    if is_mentor?(user)
      guest = self.user
      phone_number = self.mentor.user.phone
      self.update(mentor_sms_sent_at: Time.now)
    else
      guest = self.mentor.user
      phone_number = self.user.phone
      self.update(user_sms_sent_at: Time.now)
    end
    # RestClient.post(APP_CONFIG[:sms_provider_url], text: "#{guest.fullname} is ready and waiting for todays mentoring session", msisdn: phone_number)
  end

  def is_mentor?(currentuser)
    currentuser == self.user ? false : true
  end

  def guest(currentuser)
    currentuser == self.user ? self.mentor.user.fullname : self.user.fullname
  end

  def to_be_rescheduled?(new_suggested_time)
    self.suggested_meeting_at != Time.zone.parse(new_suggested_time).to_datetime
  end
end
 