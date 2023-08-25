module TimelineEvents
  class WasLastTargetService
    def initialize(submission)
      @submission = submission
    end

    def was_last_target?
      return false if milestone_targets.empty?

      if student.team.present?
        targets_passed?(milestone_targets.team, student) &&
          students.all? { |s| targets_passed?(milestone_targets.student, s) }
      else
        targets_passed?(milestone_targets, student)
      end
    end

    private

    def student
      @student ||= @submission.students.first
    end

    def students
      @students ||= student.team.present? ? student.team.students : [student]
    end

    def course
      student.course
    end

    def milestone_targets
      course.targets.milestone
    end

    def targets_passed?(targets, student)
      TimelineEvent
        .includes(:timeline_event_owners)
        .where(
          target: targets,
          timeline_event_owners: {
            student_id: student.id
          }
        )
        .where.not(passed_at: nil)
        .pluck(:target_id)
        .uniq
        .count == targets.count
    end
  end
end
