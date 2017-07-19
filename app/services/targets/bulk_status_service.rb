module Targets
  class BulkStatusService
    def initialize(founder)
      @founder = founder
      @level_number = founder.startup.level.number
    end

    # returns the status for a given target_id
    def status(target_id)
      statuses[target_id][:status]
    end

    # returns submitted_at for a given target_id, if applicable
    def submitted_at(target_id)
      statuses[target_id][:submitted_at]
    end

    # return number of completed targets
    def completed_targets_count
      statuses.values.select { |t| t[:status] == :complete }.count
    end

    private

    # returns status and submission date for all applicable targets
    def statuses
      @statuses ||= submitted_targets_statuses.merge(unsubmitted_targets_statuses)
    end

    def submitted_targets_statuses
      @submitted_targets_statuses ||= begin
        founder_events = @founder.timeline_events.where.not(target_id: nil)
          .where(target: Target.founder)
          .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")

        startup_events = @founder.startup.timeline_events.where.not(target_id: nil)
          .where(target: Target.not_founder)
          .select("DISTINCT ON(target_id) *").order("target_id, created_at DESC")

        (founder_events + startup_events).each_with_object({}) do |event, result|
          result[event.target_id] = {
            status: target_status(event),
            submitted_at: event.created_at.iso8601
          }
        end
      end
    end

    # mapping from the event's verified status to the associated targets completion status, accounting for iteration mismatches
    def target_status(event)
      target = applicable_targets.find { |t| t.id == event.target_id }
      if target&.target_group_id.present? && event.iteration != @founder.startup.iteration
        Target::STATUS_PENDING
      else
        case event.status
          when TimelineEvent::STATUS_VERIFIED then Target::STATUS_COMPLETE
          when TimelineEvent::STATUS_NOT_ACCEPTED then Target::STATUS_NOT_ACCEPTED
          when TimelineEvent::STATUS_NEEDS_IMPROVEMENT then Target::STATUS_NEEDS_IMPROVEMENT
          else Target::STATUS_SUBMITTED
        end
      end
    end

    def unsubmitted_targets_statuses
      applicable_targets.each_with_object({}) do |target, result|
        # skip if submitted target
        next if submitted_targets_statuses[target.id].present?

        result[target.id] = {
          status: unavailable_or_pending?(target),
          submitted_at: nil
        }
      end
    end

    # all applicable targets for the founder
    def applicable_targets
      @applicable_targets ||= begin
        vanilla_targets = filter_for_level(Target.joins(target_group: :level))
        chores = filter_for_level(Target.where(chore: true).joins(:level))
        sessions = filter_for_level(Target.where.not(session_at: nil).joins(:level))
        vanilla_targets + chores + sessions
      end
    end

    # Filter the given set of targets/chores/sessions based on current level.
    #
    # Only level zero targets are returned if current level is zero. Else,
    # all targets between level one and current level are returned - except for sessions.
    # For sessions, the upper limit is the maximum available level.
    def filter_for_level(targets)
      if @level_number.zero?
        targets.where('levels.number = ?', 0)
      else
        maximum_level_number = targets.first&.session_at.present? ? Level.maximum.number : @level_number
        targets.where('levels.number BETWEEN ? AND ?', 1, maximum_level_number)
      end
    end

    def unavailable_or_pending?(target)
      prerequisites_completed?(target) ? Target::STATUS_PENDING : Target::STATUS_UNAVAILABLE
    end

    def prerequisites_completed?(target)
      prerequisites = all_target_prerequisites[target.id]
      return true if prerequisites.blank?

      prerequisites.all? { |id| submitted_targets_statuses[id].present? } && prerequisites.all? { |id| submitted_targets_statuses[id][:status].in? [Target::STATUS_COMPLETE, Target::STATUS_NEEDS_IMPROVEMENT] }
    end

    # all target-prerequisite mappings
    def all_target_prerequisites
      @all_target_prerequisites ||= TargetPrerequisite.all.pluck(:target_id, :prerequisite_target_id).each_with_object({}) do |(target_id, prerequisite_target_id), mapping|
        mapping[target_id] ||= []
        mapping[target_id] << prerequisite_target_id
      end
    end
  end
end
