module TimelineEvents
  class WasLastTargetService
    def initialize(submission)
      @submission = submission
    end

    def was_last_target?
      return false unless student.level == last_level

      return false if final_milestone_targets.empty?

      final_milestone_targets.all? do |target|
        if target.team_target?
          # Need to check for just one student.
          status_passed?(target, student)
        else
          # Need to check for each student in team.
          students.all? { |s| status_passed?(target, s) }
        end
      end
    end

    private

    def status_passed?(target, student)
      Targets::StatusService.new(target, student).status_from_event ==
        Targets::StatusService::STATUS_PASSED
    end

    def student
      @student ||= @submission.founders.first
    end

    def students
      @students ||= student.team.present? ? student.team.founders : [student]
    end

    def course
      student.course
    end

    def last_level
      @last_level ||= course.levels.order(number: :desc).first
    end

    def final_milestone_targets
      Target
        .live
        .joins(target_group: :level)
        .where(
          target_groups: {
            milestone: true
          },
          levels: {
            id: last_level.id
          }
        )
    end
  end
end
