module Students
  # This service should be used to check whether a student is eligible to _level up_ - to move up a level in the main
  # program - it does this by checking whether all required milestone targets have been completed (strict progression)
  # or attempted (limited & unlimited progression).
  class LevelUpEligibilityService
    def initialize(student)
      @student = student
      @team_members_pending = false
    end

    ELIGIBILITY_ELIGIBLE = -'Eligible'
    ELIGIBILITY_AT_MAX_LEVEL = -'AtMaxLevel'
    ELIGIBILITY_NO_MILESTONES = -'NoMilestonesInLevel'
    ELIGIBILITY_CURRENT_LEVEL_INCOMPLETE = -'CurrentLevelIncomplete'
    ELIGIBILITY_PREVIOUS_LEVEL_INCOMPLETE = -'PreviousLevelIncomplete'
    ELIGIBILITY_TEAM_MEMBERS_PENDING = -'TeamMembersPending'
    ELIGIBILITY_DATE_LOCKED = -'DateLocked'

    MINIMUM_REQUIRED_LEVEL_ELIGIBLE_STATUSES = [Targets::StatusService::STATUS_PASSED].freeze

    def eligible?
      eligibility == ELIGIBILITY_ELIGIBLE
    end

    def eligibility
      @eligibility ||= begin
        if next_level.blank?
          ELIGIBILITY_AT_MAX_LEVEL
        elsif next_level.unlock_at&.future? && regular_student?
          ELIGIBILITY_DATE_LOCKED
        elsif current_level_milestone_targets.any?
          current_level_targets_attempted = current_level_milestone_targets.all? do |target|
            target_eligible?(target, current_level_eligible_statuses)
          end

          if current_level_targets_attempted
            minimum_required_level_completed = minimum_required_level_milestone_targets.all? do |target|
              target_eligible?(target, MINIMUM_REQUIRED_LEVEL_ELIGIBLE_STATUSES)
            end

            if minimum_required_level_completed
              @team_members_pending ? ELIGIBILITY_TEAM_MEMBERS_PENDING : ELIGIBILITY_ELIGIBLE
            else
              ELIGIBILITY_PREVIOUS_LEVEL_INCOMPLETE
            end
          else
            ELIGIBILITY_CURRENT_LEVEL_INCOMPLETE
          end
        else
          ELIGIBILITY_NO_MILESTONES
        end
      end
    end

    private

    def next_level
      @next_level ||= course.levels.find_by(number: current_level.number + 1)
    end

    def regular_student?
      return false if @student.user.school_admin.present?

      coach = @student.user.faculty
      return false if coach.present? && team.course.in?(coach.courses)

      true
    end

    def current_level_eligible_statuses
      @current_level_eligible_statuses ||= case course.progression_behavior
        when Course::PROGRESSION_BEHAVIOR_STRICT
          [Targets::StatusService::STATUS_PASSED]
        when Course::PROGRESSION_BEHAVIOR_LIMITED, Course::PROGRESSION_BEHAVIOR_UNLIMITED
          [
            Targets::StatusService::STATUS_SUBMITTED,
            Targets::StatusService::STATUS_PASSED
          ]
        else
          raise "Unexpected progression behavior #{course.progression_behavior}"
      end
    end

    def current_level_milestone_targets
      milestone_groups = current_level.target_groups.where(milestone: true)
      Target.where(target_group: milestone_groups).live
    end

    def minimum_required_level_milestone_targets
      case course.progression_behavior
        when Course::PROGRESSION_BEHAVIOR_LIMITED
          if current_level.number > course.progression_limit
            minimum_required_level_number = current_level.number - course.progression_limit
            minimum_required_level = current_level.course.levels.find_by(number: minimum_required_level_number)

            raise 'Could not find minimum required level for computing level up eligibility' if minimum_required_level.blank?

            milestone_groups = minimum_required_level.target_groups.where(milestone: true)
            Target.where(target_group: milestone_groups).live
          else
            Target.none
          end
        when Course::PROGRESSION_BEHAVIOR_UNLIMITED, Course::PROGRESSION_BEHAVIOR_STRICT
          Target.none
        else
          raise "Unexpected progression behavior #{course.progression_behavior}"
      end
    end

    def target_eligible?(target, eligibility)
      if target.individual_target?
        completed_students = team.founders.all.select do |student|
          target.status(student).in?(eligibility)
        end

        if @student.in?(completed_students)
          # Mark that some teammates haven't yet completed target if applicable.
          @team_members_pending ||= completed_students.count != team.founders.count

          # Student has completed this target.
          true
        else
          false
        end
      else
        target.status(@student).in?(eligibility)
      end
    end

    def team
      @team ||= @student.startup
    end

    def current_level
      @current_level ||= team.level
    end

    def course
      @course ||= team.course
    end
  end
end
