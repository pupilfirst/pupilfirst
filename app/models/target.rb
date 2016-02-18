# encoding: utf-8
# frozen_string_literal: true

class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'Faculty'
  has_many :timeline_events

  STATUS_PENDING = -'pending'
  STATUS_DONE = -'done'

  # The following definitions of pending and expired is naive. A correct check requires the use of the done_for_viewer?
  # method on individual targets by supplying the viewer.
  scope :pending, -> { where(status: STATUS_PENDING).where('due_date >= ? OR due_date IS NULL', Time.now).order(due_date: 'desc') }
  scope :expired, -> { where(status: STATUS_PENDING).where('due_date < ?', Time.now).order(due_date: 'desc') }

  scope :completed, -> { where(status: STATUS_DONE).order(completed_at: 'desc') }
  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_target_roles, -> { where.not(role: target_roles) }
  scope :due_on, -> (date) { where(due_date: date.beginning_of_day..date.end_of_day) }

  ROLE_FOUNDER = -'founder'

  def self.target_roles
    [ROLE_FOUNDER]
  end

  # See en.yml's target.role
  def self.valid_roles
    target_roles + Founder.valid_roles
  end

  # See en.yml's target.status
  def self.valid_statuses
    %w(pending done)
  end

  validates_presence_of :startup_id, :assigner_id, :role, :title, :description, :status
  validates_inclusion_of :role, in: valid_roles
  validates_inclusion_of :status, in: valid_statuses

  just_define_datetime_picker :due_date
  just_define_datetime_picker :completed_at

  # A target is pending if it isn't marker done, or isn't expired.
  def pending?
    !(done? || expired?)
  end

  # This is a naive check. See done_for_viewer?
  def done?
    status == STATUS_DONE
  end

  # This checks for presence of a linked verified timeline event if role of target is founder.
  def done_for_viewer?(viewer)
    return true if done?
    return done? unless role == ROLE_FOUNDER
    timeline_events.where(founder: viewer).merge(TimelineEvent.verified).present?
  end

  # Stored status must be pending, and due date must be present and in the past.
  def expired?
    (status == STATUS_PENDING) && due_date? && (due_date < Time.now)
  end

  # Set and clear completed at, depending on the value of stored status.
  before_save do
    self.completed_at = (status == STATUS_DONE) ? completed_at || Time.now : nil
  end

  def complete!
    update!(status: STATUS_DONE)
  end

  def founder?
    role == Target::ROLE_FOUNDER
  end

  # Notify founders about a new or revised target on public slack
  after_create :notify_new_target
  after_update :notify_revision, if: :crucial_revision?

  def notify_new_target
    PublicSlackTalk.post_message message: details_as_slack_message, founders: startup.founders
  end

  def notify_revision
    PublicSlackTalk.post_message message: revision_as_slack_message, founders: startup.founders
  end

  def crucial_revision?
    title_changed? || description_changed? || completion_instructions_changed? || due_date_changed?
  end

  def details_as_slack_message
    message = "Hey! #{assigner.name} has assigned your startup, #{startup.product_name} a new target: *#{title}*\n"
    message += "Description: \"#{ApplicationController.helpers.strip_tags description}\"\n"
    message += "He has also provided <#{resource_url}|a useful link> to assist you.\n" if resource_url.present?
    message += "The due date to complete this target is :exclamation: *#{due_date.strftime('%A, %d %b %Y %l:%M %p')}*" if due_date.present?
    message
  end

  def revision_as_slack_message
    message = "Hey! #{assigner.name} has revised the target (#{title}) he recently assigned to your startup, #{startup.product_name}\n"
    message += "The revised title is: #{title}" if title_changed?
    message += "The description now reads: \"#{ApplicationController.helpers.strip_tags description}\"\n" if description_changed?
    message += "Completion Instructions were modified to: \"#{completion_instructions}\"\n" if completion_instructions_changed?
    message += ":exclamation: The due date has been modified to *#{due_date.strftime('%A, %d %b %Y %l:%M %p')}* :exclamation:" if due_date_changed?
    message
  end

  # Notify all founders of the startup about expiry in 5 days
  def send_mild_reminder_on_slack
    return unless startup.present?

    # notify each founder
    startup.founders.each do |founder|
      next unless founder.slack_user_id.present?
      PublicSlackTalk.post_message message: mild_slack_reminder, founder: founder
    end
  end

  # Slack message to remind founder of expiry in 5 days
  def mild_slack_reminder
    ":timer_clock: *Reminder:* Your startup has a target - _#{title}_ - assigned by #{assigner.name} due in 5 days!"
  end

  # Notify all founders of the startup about expiry in 2 days
  def send_strong_reminder_on_slack
    return unless startup.present?

    # notify each founder
    startup.founders.each do |founder|
      next unless founder.slack_user_id.present?
      PublicSlackTalk.post_message message: strong_slack_reminder, founder: founder
    end
  end

  # Slack message to remind founder of expiry in 2 days
  def strong_slack_reminder
    ":exclamation: *Urgent:* It seems that the target - _#{title}_ - assigned to your startup "\
    "by #{assigner.name} due in 2 days is not yet complete! Please complete the same at the "\
    "earliest and submit the corresponding timeline entry for verification!"
  end
end
