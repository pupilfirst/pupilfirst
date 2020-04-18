module TimelineEvents
  class WasLastTargetService
    def initialize(submission)
      @submission = submission
    end

    def was_last_target?
      return false unless startup.level == last_level

      return false if final_milestone_targets.empty?

      final_milestone_targets.all? do |target|
        if target.team_target?
          # Need to check for just one student.
          target.status(student) == Targets::StatusService::STATUS_PASSED
        else
          # Need to check for each student in team.
          students.all? do |s|
            target.status(s) == Targets::StatusService::STATUS_PASSED
          end
        end
      end
    end

    private

    def student
      @student ||= @submission.founders.first
    end

    def students
      @students ||= startup.founders
    end

    def startup
      @startup ||= student.startup
    end

    def course
      startup.course
    end

    def last_level
      @last_level ||= course.levels.order(number: :desc).first
    end

    def final_milestone_targets
      Target.live.joins(target_group: :level).where(target_groups: { milestone: true }, levels: { id: last_level.id })
    end
  end
end
