# encoding: utf-8
# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :assignee, polymorphic: true
  belongs_to :assigner, class_name: 'Faculty'
  belongs_to :timeline_event_type, optional: true
  has_many :timeline_events, as: :task
  has_many :target_prerequisites
  has_many :prerequisite_targets, through: :target_prerequisites
  belongs_to :target_group
  has_one :program_week, through: :target_group
  has_one :batch, through: :target_group

  mount_uploader :rubric, RubricUploader

  scope :founder, -> { where(role: ROLE_FOUNDER) }
  scope :not_founder, -> { where.not(role: ROLE_FOUNDER) }
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

  TYPE_TODO = 'Todo'
  TYPE_ATTEND = 'Attend'
  TYPE_READ = 'Read'
  TYPE_LEARN = 'Learn'

  def self.valid_target_types
    [TYPE_TODO, TYPE_ATTEND, TYPE_READ, TYPE_LEARN].freeze
  end

  # Need to allow these two to be read for AA form.
  attr_reader :startup_id, :founder_id

  validates :target_type, inclusion: { in: valid_target_types }
  validates :role, presence: true, inclusion: { in: valid_roles }
  validates :title, presence: true
  validates :description, presence: true
  validates :days_to_complete, presence: true

  def founder_role?
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
  # after_update :notify_revision, if: :crucial_revision?

  def notify_revision
    PublicSlackTalk.post_message message: revision_as_slack_message, founders: slack_targets
  end

  def crucial_revision?
    title_changed? || description_changed? || completion_instructions_changed?
  end

  def revision_as_slack_message
    message = "Hey! #{assigner.name} has revised the target (<#{Rails.application.routes.url_helpers.startup_url(startup)}|#{title}>) "\
    "he recently assigned to #{assignee.is_a?(Startup) ? 'your startup ' + startup.product_name : 'you'}\n"
    message += "The revised title is: #{title}\n" if title_changed?
    message += "The description now reads: \"#{ApplicationController.helpers.strip_tags description}\"\n" if description_changed?
    message += "Completion Instructions were modified to: \"#{completion_instructions}\"\n" if completion_instructions_changed?
    message
  end

  def rubric_filename
    rubric.sanitized_file.original_filename
  end

  # due date for the target calculated using days_to_complete starting from program_week start.
  def due_date
    return nil unless days_to_complete.present?

    week_start = target_group&.program_week&.start_date
    return nil unless week_start.present?

    week_start + days_to_complete.days
  end

  def status(founder)
    @status ||= {}
    @status[founder.id] ||= Targets::StatusService.new(self, founder).status
  end

  def stats_service
    @stats_service ||= Targets::StatsService.new(self)
  end
end
