module Founders
  class TargetStatusService
    def initialize(founder)
      @founder = founder
    end

    def status(target_id)
      status_entries[target_id][:status]
    end

    def prerequisite_targets(target_id)
      target_ids = all_target_prerequisites[target_id]
      return [] if target_ids.blank?

      applicable_targets.where(id: target_ids).as_json(only: [:id])
    end

    def evaluation_criteria(target_id)
      all_target_evaluation_criteria[target_id]
    end

    private

    # TODO: Examine if there is a cleaner implementation
    # rubocop:disable Metrics/AbcSize
    def status_entries
      @status_entries ||= begin
        # Populate with all sumbitted targets first
        entries = submitted_target_entries

        # followed by level-locked targets...
        level_locked_targets = applicable_targets.where.not(id: entries.keys)
          .where('levels.number > ?', founder_level.number)
        entries.merge!(status_fields(level_locked_targets, :level_locked))

        # followed by milestone-locked targets, if applicable...
        if previous_milestones_incomplete?(entries)
          milestone_locked_targets = applicable_targets.where.not(id: entries.keys)
            .where(target_groups: { milestone: true, level: founder_level })
          entries.merge!(status_fields(milestone_locked_targets, :milestone_locked))
        end

        # followed by prerequisite-locked targets...
        prerequisite_locked_targets = applicable_targets.where.not(id: entries.keys)
          .where(id: TargetPrerequisite.where(prerequisite_target: blocking_prerequisite_ids(entries)).distinct.pluck(:target_id))
        entries.merge!(status_fields(prerequisite_locked_targets, :prerequisite_locked))

        # and finally all remaining pending targets.
        pending_targets = applicable_targets.where.not(id: entries.keys)
        entries.merge!(status_fields(pending_targets, :pending))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def submitted_target_entries
      @submitted_target_entries ||= begin
        @founder.latest_submissions.each_with_object({}) do |submission, result|
          result[submission.target_id] = {
            status: status_from_submission(submission),
            submitted_at: submission.created_at.iso8601
          }
        end
      end
    end

    def status_from_submission(submission)
      return statuses[:passed] if submission.passed_at?

      submission.evaluator_id? ? statuses[:failed] : statuses[:submitted]
    end

    def status_fields(targets, status_key)
      targets.each_with_object({}) do |target, result|
        result[target.id] = {
          status: statuses[status_key],
          submitted_at: nil
        }
      end
    end

    def previous_milestones_incomplete?(entries)
      return false if founder_level.number == 1

      previous_level = @founder.school.levels.where(number: founder_level.number - 1)
      previous_level_milestones = applicable_targets.where(
        target_groups: {
          level: previous_level,
          milestone: true
        }
      )
      previous_level_milestones.any? { |target| entries.dig(target.id, :status) != Targets::StatusService::STATUS_PASSED }
    end

    # All prerequiste_ids which are not passed, archived or orphaned (i.e not assigned to a target group)
    def blocking_prerequisite_ids(entries)
      all_applicable_prerequisite_ids = TargetPrerequisite.where(target: applicable_targets).distinct.pluck(:prerequisite_target_id)

      passed_prerequisites = all_applicable_prerequisite_ids.select do |target_id|
        entries.dig(target_id, :status) == Targets::StatusService::STATUS_PASSED
      end

      archived_prerequisites = Target.where(id: all_applicable_prerequisite_ids, archived: true)
      orphaned_prerequisites = Target.where(id: all_applicable_prerequisite_ids, target_group_id: nil)
      all_applicable_prerequisite_ids - passed_prerequisites - archived_prerequisites - orphaned_prerequisites
    end

    def applicable_targets
      Target.live.joins(target_group: :level).where(target_groups: { level: open_levels })
    end

    def open_levels
      @open_levels ||= begin
        minimum_level_number = startup.level.number.zero? ? 0 : 1
        levels = startup.school.levels.where('levels.number >= ?', minimum_level_number)
        levels.where(unlock_on: nil).or(levels.where('unlock_on <= ?', Date.today)).to_a
      end
    end

    def startup
      @startup ||= @founder.startup
    end

    def founder_level
      @founder_level ||= @founder.level
    end

    # TODO: Confirm usage and verify implementation
    def all_target_prerequisites
      @all_target_prerequisites ||= begin
        target_prerequisites = TargetPrerequisite.joins(:target, prerequisite_target: :target_group).includes(prerequisite_target: :target_group)

        target_prerequisites.each_with_object({}) do |target_prerequisite, mapping|
          next if target_prerequisite.prerequisite_target.archived?
          next if target_prerequisite.prerequisite_target.target_group.blank?

          mapping[target_prerequisite.target_id] ||= []
          mapping[target_prerequisite.target_id] << target_prerequisite.prerequisite_target_id
        end
      end
    end

    def all_target_evaluation_criteria
      @all_target_evaluation_criteria ||= Target.joins(:evaluation_criteria).includes(target_evaluation_criteria: :evaluation_criterion).each_with_object({}) do |target, mapping|
        mapping[target.id] = target.evaluation_criteria.pluck(:id)
      end
    end

    def statuses
      {
        passed: Targets::StatusService::STATUS_PASSED,
        failed: Targets::StatusService::STATUS_FAILED,
        submitted: Targets::StatusService::STATUS_SUBMITTED,
        pending: Targets::StatusService::STATUS_PENDING,
        level_locked: Targets::StatusService::STATUS_LEVEL_LOCKED,
        milestone_locked: Targets::StatusService::STATUS_MILESTONE_LOCKED,
        prerequisite_locked: Targets::StatusService::STATUS_PREREQUISITE_LOCKED
      }
    end
  end
end
