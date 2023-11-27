class MigrateTargetsToAssignments < ActiveRecord::Migration[6.1]

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
        request_source: 'User',
        embed_code: embed_code(target.link_to_complete),
        last_resolved_at: Time.zone.now
      },
      sort_index: target_version.content_blocks.maximum(:sort_index) + 1
    )
  end

  def change
    assignments = []
    Target.includes(:quiz, :target_prerequisites).find_each do |target|
      assignment_hash = {
        :target_id => target.id,
        :role => target.role,
        :completion_instructions => target.completion_instructions,
        :milestone => target.milestone,
        :milestone_number => target.milestone_number,
        :checklist => target.checklist,
        :created_at => target.created_at,
        :updated_at => target.updated_at,
        :archived => false
      }
      if target.mark_as_complete?
        if !target.target_prerequisites.empty? or !target.prerequisite_targets.empty? or target.milestone?
          # convert mark as complete to a form submit assignment
          assignment_hash[:checklist] = [{"kind"=>"multiChoice", "title"=>"Mark this target as completed?", "metadata"=>{"choices"=>["Yes"], "allowMultiple"=>false}, "optional"=>false}]
        else
          target.timeline_events.destroy_all
          # skip creating assignment
          next
        end
      end

      if target.link_to_complete.present?
        create_embed_block(target)
        if !target.target_prerequisites.empty? or !target.prerequisite_targets.empty? or target.milestone?
          assignment_hash[:checklist] = [{"kind"=>"multiChoice", "title"=>"Have you gone through the shared link?", "metadata"=>{"choices"=>["Yes"], "allowMultiple"=>false}, "optional"=>false}]
        else
          target.timeline_events.destroy_all
          # skip creating assignment
          next
        end
      end
      assignments.append(assignment_hash)
    end

    Assignment.insert_all(assignments)

    #TODO - is there a way to bulk update different records with different values
    Quiz.includes(target: :assignments).find_each do |quiz|
      quiz.assignment = quiz.target.assignments.first
      quiz.save
    end

    assignment_evaluation_criterions = []
    assignment_prerequisites = []
    Target.joins(:assignments).includes(:assignments, :evaluation_criteria, :prerequisite_targets).find_each do |target|
      assignment_id = target.assignments.first.id
      target.evaluation_criteria.each do |evaluation_criteria|
        assignment_evaluation_criteria = {
          :assignment_id => assignment_id,
          :evaluation_criterion_id => evaluation_criteria.id
        }
        assignment_evaluation_criterions.append(assignment_evaluation_criteria)
      end
      target.prerequisite_targets.each do |prerequisite_target|
        assignment_prerequisite = {
          :assignment_id => assignment_id,
          :prerequisite_assignment_id => prerequisite_target.assignments.first.id
        }
        assignment_prerequisites.append(assignment_prerequisite)
      end
    end

    if !assignment_evaluation_criterions.empty?
      AssignmentEvaluationCriterion.insert_all(assignment_evaluation_criterions)
    end

    if !assignment_prerequisites.empty?
      AssignmentPrerequisite.insert_all(assignment_prerequisites)
    end

  end
end
