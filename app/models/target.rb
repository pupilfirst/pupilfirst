# encoding: utf-8
# frozen_string_literal: true

class Target < ActiveRecord::Base
  belongs_to :assignee, polymorphic: true
  belongs_to :assigner, class_name: 'Faculty'
  belongs_to :target_template
  has_many :timeline_events

  mount_uploader :rubric, RubricUploader

  STATUS_PENDING = 'pending'
  STATUS_DONE = 'done'

  # The following definitions of pending and expired is naive. A correct check requires the use of the done_for_viewer?
  # method on individual targets by supplying the viewer.
  scope :pending, -> { where(status: STATUS_PENDING).where('due_date >= ? OR due_date IS NULL', Time.now) }
  scope :expired, -> { where(status: STATUS_PENDING).where('due_date < ?', Time.now) }

  scope :completed, -> { where(status: STATUS_DONE) }
  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_target_roles, -> { where.not(role: target_roles) }
  scope :due_on, -> (date) { where(due_date: date.beginning_of_day..date.end_of_day) }

  scope :for_founders_in_batch, -> (batch) { where(assignee: batch.founders.not_dropped_out.not_exited) }
  scope :for_startups_in_batch, -> (batch) { where(assignee: batch.startups.not_dropped_out) }

  ROLE_FOUNDER = 'founder'

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

  # Need to allow these two to be read for AA form.
  attr_reader :startup_id, :founder_id

  validates_presence_of :assignee_id, :assignee_type, :assigner_id, :role, :title, :description, :status
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

  def slack_targets
    @slack_targets ||= assignee.is_a?(Startup) ? assignee.founders : [assignee]
  end

  def startup
    @startup ||= assignee.is_a?(Startup) ? assignee : assignee.startup
  end

  # TODO: Probably find a way to move this to the corresponding admin controller update action
  # attempts to use after_update hook of activeadmin, overriding its update action or writing a after_filter for update didnt work
  after_update :notify_revision, if: :crucial_revision?

  def notify_revision
    PublicSlackTalk.post_message message: revision_as_slack_message, founders: slack_targets
  end

  def crucial_revision?
    title_changed? || description_changed? || completion_instructions_changed? || due_date_changed?
  end

  def revision_as_slack_message
    message = "Hey! #{assigner.name} has revised the target (<#{Rails.application.routes.url_helpers.startup_url(startup)}|#{title}>) "\
    "he recently assigned to #{assignee.is_a?(Startup) ? 'your startup ' + startup.product_name : 'you'}\n"
    message += "The revised title is: #{title}\n" if title_changed?
    message += "The description now reads: \"#{ApplicationController.helpers.strip_tags description}\"\n" if description_changed?
    message += "Completion Instructions were modified to: \"#{completion_instructions}\"\n" if completion_instructions_changed?
    message += ":exclamation: The due date has been modified to *#{due_date.strftime('%A, %d %b %Y %l:%M %p')}* :exclamation:" if due_date_changed?
    message
  end

  def rubric_filename
    rubric.sanitized_file.original_filename
  end

  # used in admin 'Targets Overview' page to count targets which satisfy batch, status and template conditions
  def self.shortlist(batch, status_scope, template)
    batch_scope = template.founder_role? ? :for_founders_in_batch : :for_startups_in_batch

    Target.send(batch_scope, batch).send(status_scope).where(target_template: template)
  end
end
