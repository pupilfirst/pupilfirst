class TargetsToAssignmentsMigrations < ActiveRecord::Migration[6.1]
  class Target < ApplicationRecord
    has_many :timeline_events, dependent: :restrict_with_error
    has_one :quiz, dependent: :restrict_with_error
    has_many :target_prerequisites, dependent: :destroy
    has_many :prerequisite_targets, through: :target_prerequisites
    has_many :target_evaluation_criteria, dependent: :destroy
    has_many :evaluation_criteria, through: :target_evaluation_criteria
    has_many :target_versions, dependent: :destroy
    has_many :assignments, dependent: :restrict_with_error

    def mark_as_complete?
      not (quiz.present? or checklist.present? or link_to_complete.present?)
    end

    def current_target_version
      target_versions.order(created_at: :desc).first
    end
  end

  class TimelineEvent < ApplicationRecord
    belongs_to :target
    has_many :timeline_event_owners
  end

  class TimelineEventOwner < ApplicationRecord
    belongs_to :timeline_event
    belongs_to :student
  end

  class Quiz < ApplicationRecord
    belongs_to :target
    belongs_to :assignment, optional: true
  end

  class TargetPrerequisite < ApplicationRecord
    belongs_to :target
    belongs_to :prerequisite_target, class_name: "Target"
  end

  class TargetEvaluationCriterion < ApplicationRecord
    belongs_to :target
    belongs_to :evaluation_criterion
  end

  class TargetVersion < ApplicationRecord
    belongs_to :target
    has_many :content_blocks, dependent: :destroy
  end

  class ContentBlock < ApplicationRecord
    belongs_to :target_version

    BLOCK_TYPE_EMBED = -"embed"
  end

  class Assignment < ApplicationRecord
    belongs_to :target
    has_one :quiz, dependent: :restrict_with_error
  end

  def embed_code(url)
    @embed_code ||= ::Oembed::Resolver.new(url).embed_code
  rescue ::Oembed::Resolver::ProviderNotSupported
    nil
  end

  def create_embed_block(target)
    target_version = target.current_target_version
    target_version.content_blocks.create!(
      block_type: ContentBlock::BLOCK_TYPE_EMBED,
      content: {
        url: target.link_to_complete,
        request_source: "User",
        embed_code: embed_code(target.link_to_complete),
        last_resolved_at: Time.zone.now
      },
      sort_index: target_version.content_blocks.maximum(:sort_index) + 1
    )
  end

  def delete_timeline_events(target)
    timeline_event_ids = target.timeline_events.pluck(:id)
    TimelineEventOwner.where(timeline_event_id: timeline_event_ids).delete_all
  end

  def add_page_reads_for_timeline_events
    TimelineEventOwner
      .includes(:timeline_event)
      .find_in_batches do |timeline_event_owners|
        page_reads_array = []
        timeline_event_owners.each do |timeline_event_owner|
          page_read_hash = {
            target_id: timeline_event_owner.timeline_event.target_id,
            student_id: timeline_event_owner.student_id,
            created_at: timeline_event_owner.timeline_event.created_at
          }
          page_reads_array.append(page_read_hash)
        end
        PageRead.insert_all(page_reads_array)
      end
  end

  def separate_assignments_from_targets
    assignments = []
    Target
      .includes(:quiz, :target_prerequisites)
      .find_each do |target|
        assignment_hash = {
          target_id: target.id,
          role: target.role,
          completion_instructions: target.completion_instructions,
          milestone: target.milestone,
          milestone_number: target.milestone_number,
          checklist: target.checklist,
          created_at: target.created_at,
          updated_at: target.updated_at,
          archived: false
        }
        if target.mark_as_complete?
          # convert to assignment if target has prerequisites or target is a prerequisiste or target is a milestone
          if !target.prerequisite_targets.empty? or
               !TargetPrerequisite.where(prerequisite_target: target).empty? or
               target.milestone?
            # convert mark as complete to a form submit assignment
            assignment_hash[:checklist] = [
              {
                "kind" => "multiChoice",
                "title" => "Mark this target as completed?",
                "metadata" => {
                  "choices" => ["Yes"],
                  "allowMultiple" => false
                },
                "optional" => false
              }
            ]
          else
            delete_timeline_events(target)
            # skip creating assignment
            next
          end
        end

        if target.link_to_complete.present?
          create_embed_block(target)
          if !target.prerequisite_targets.empty? or
               !TargetPrerequisite.where(prerequisite_target: target).empty? or
               target.milestone?
            assignment_hash[:checklist] = [
              {
                "kind" => "multiChoice",
                "title" => "Have you gone through the shared link?",
                "metadata" => {
                  "choices" => ["Yes"],
                  "allowMultiple" => false
                },
                "optional" => false
              }
            ]
          else
            delete_timeline_events(target)
            # skip creating assignment
            next
          end
        end
        assignments.append(assignment_hash)
      end

    Assignment.insert_all(assignments)

    Quiz
      .includes(target: :assignments)
      .find_each do |quiz|
        quiz.assignment = quiz.target.assignments.first
        quiz.save
      end

    assignment_evaluation_criterions = []
    assignment_prerequisites = []
    Target
      .joins(:assignments)
      .includes(:assignments, :evaluation_criteria, :prerequisite_targets)
      .find_each do |target|
        assignment_id = target.assignments.first.id
        target.evaluation_criteria.each do |evaluation_criteria|
          assignment_evaluation_criteria = {
            assignment_id: assignment_id,
            evaluation_criterion_id: evaluation_criteria.id
          }
          assignment_evaluation_criterions.append(
            assignment_evaluation_criteria
          )
        end
        target.prerequisite_targets.each do |prerequisite_target|
          assignment_prerequisite = {
            assignment_id: assignment_id,
            prerequisite_assignment_id: prerequisite_target.assignments.first.id
          }
          assignment_prerequisites.append(assignment_prerequisite)
        end
      end

    if !assignment_evaluation_criterions.empty?
      AssignmentsEvaluationCriterion.insert_all(
        assignment_evaluation_criterions
      )
    end

    if !assignment_prerequisites.empty?
      AssignmentsPrerequisiteAssignment.insert_all(assignment_prerequisites)
    end
  end

  def up
    create_table :assignments do |t|
      t.references :target, null: false, foreign_key: true
      t.string :role
      t.jsonb :checklist
      t.string :completion_instructions
      t.boolean :milestone
      t.integer :milestone_number
      t.boolean :archived

      t.timestamps
    end

    create_join_table :assignments, :evaluation_criteria do |t|
      t.index %i[assignment_id evaluation_criterion_id],
              name: "index_assignment_evaluation_criterion"
      t.index %i[evaluation_criterion_id assignment_id],
              name: "index_evaluation_criterion_assignment"
    end

    create_join_table :assignments, :prerequisite_assignments do |t|
      t.index %i[assignment_id prerequisite_assignment_id],
              name: "index_assignment_prerequisite"
      t.index %i[prerequisite_assignment_id assignment_id],
              name: "index_prerequisite_assignment"
    end

    create_table :page_reads do |t|
      t.references :target, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.datetime :created_at
    end

    add_index :page_reads, %i[student_id target_id], unique: true

    add_reference :quizzes, :assignment, null: true, foreign_key: true

    add_page_reads_for_timeline_events

    separate_assignments_from_targets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
