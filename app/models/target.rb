# encoding: utf-8
# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :assignee, polymorphic: true
  belongs_to :assigner, class_name: 'Faculty'
  belongs_to :target_group
  belongs_to :batch
  has_many :timeline_events

  mount_uploader :rubric, RubricUploader

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

  TYPE_TODO = 'To Do'
  TYPE_ATTEND = 'Attend'
  TYPE_READ = 'Read'
  TYPE_LEARN = 'Learn'

  def self.valid_target_types
    [TYPE_TODO, TYPE_ATTEND, TYPE_READ, TYPE_LEARN].freeze
  end

  validates_inclusion_of :target_type, in: valid_target_types, allow_nil: true

  # Need to allow these two to be read for AA form.
  attr_reader :startup_id, :founder_id

  validates_presence_of :role, :title, :description
  validates_inclusion_of :role, in: valid_roles

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

  # used in admin 'Targets Overview' page to count targets which satisfy batch, status and template conditions
  def self.shortlist(batch, status_scope, template)
    batch_scope = template.founder_role? ? :for_founders_in_batch : :for_startups_in_batch

    Target.send(batch_scope, batch).send(status_scope).where(target_template: template)
  end
end
