module Founders
  class TargetStatusService
    STATUSES = {
      passed: Targets::StatusService::STATUS_PASSED,
      failed: Targets::StatusService::STATUS_FAILED,
      submitted: Targets::StatusService::STATUS_SUBMITTED,
      pending: Targets::StatusService::STATUS_PENDING,
      level_locked: Targets::StatusService::STATUS_LEVEL_LOCKED,
      milestone_locked: Targets::StatusService::STATUS_MILESTONE_LOCKED,
      prerequisite_locked: Targets::StatusService::STATUS_PREREQUISITE_LOCKED
    }.freeze

    def initialize(founder)
      @founder = founder
    end

    def status(target_id)
      status_entries[target_id][:status]
    end

    def submitted_at(target_id)
      status_entries[target_id][:submitted_at]
    end

    def prerequisite_targets(target_id)
      target_ids = all_target_prerequisites[target_id]
      applicable_targets.where(id: target_ids)
    end

    def grades(target_id)
      status_entries[target_id][:grades]
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def status_entries
      @status_entries ||= begin
        # Populate with all sumbitted targets first
        entries = @founder.latest_submissions.each_with_object({}) do |submission, result|
          result[submission.target_id] = {
            status: status_from_submission(submission),
            submitted_at: submission.created_at.iso8601,
            grades: grades_for_submission(submission)
          }
        end

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
        target_ids_with_blocking_prerequisites = TargetPrerequisite.where(prerequisite_target: blocking_prerequisite_ids(entries)).distinct.select(:target_id)
        prerequisite_locked_targets = applicable_targets.where.not(id: entries.keys)
          .where(id: target_ids_with_blocking_prerequisites)
        entries.merge!(status_fields(prerequisite_locked_targets, :prerequisite_locked))

        # and finally all remaining pending targets.
        pending_targets = applicable_targets.where.not(id: entries.keys)
        entries.merge!(status_fields(pending_targets, :pending))
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def status_from_submission(submission)
      return STATUSES[:passed] if submission.passed_at?

      submission.evaluator_id? ? STATUSES[:failed] : STATUSES[:submitted]
    end

    def grades_for_submission(submission)
      return unless submission.evaluator_id?

      grades = timeline_event_grades.select { |grade| grade[:submission_id] == submission.id }
      return if grades.blank?

      grades.each_with_object({}) do |grade, result|
        result[grade[:criterion_id]] = grade[:grade]
      end
    end

    def status_fields(targets, status_key)
      targets.each_with_object({}) do |target, result|
        result[target.id] = {
          status: STATUSES[status_key],
          submitted_at: nil,
          grades: nil
        }
      end
    end

    def previous_milestones_incomplete?(entries)
      return false if founder_level.number == 1

      previous_level = @founder.startup.course.levels.where(number: founder_level.number - 1)
      previous_level_milestones = applicable_targets.where(
        target_groups: {
          level: previous_level,
          milestone: true
        }
      )
      previous_level_milestones.any? { |target| entries.dig(target.id, :status) != Targets::StatusService::STATUS_PASSED }
    end

    # All prerequiste_ids which are not passed or are archived
    def blocking_prerequisite_ids(entries)
      all_applicable_prerequisite_ids = TargetPrerequisite.where(target: applicable_targets).distinct.pluck(:prerequisite_target_id)

      passed_prerequisite_ids = all_applicable_prerequisite_ids.select do |target_id|
        entries.dig(target_id, :status) == Targets::StatusService::STATUS_PASSED
      end

      archived_prerequisite_ids = Target.where(id: all_applicable_prerequisite_ids, archived: true).pluck(:id)
      non_blocking_prerequisite_ids = passed_prerequisite_ids + archived_prerequisite_ids

      all_applicable_prerequisite_ids - non_blocking_prerequisite_ids
    end

    def applicable_targets
      Target.live.joins(target_group: :level).where(target_groups: { level: open_levels })
    end

    def open_levels
      @open_levels ||= begin
        levels = startup.course.levels.where('levels.number >= ?', 1)
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

    def timeline_event_grades
      @timeline_event_grades ||= TimelineEventGrade.where(timeline_event: @founder.latest_submissions).map do |grade|
        {
          submission_id: grade.timeline_event_id,
          criterion_id: grade.evaluation_criterion_id,
          grade: grade.grade
        }
      end
    end
  end
end
