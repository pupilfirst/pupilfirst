module TimelineEvents
  class WasLastTargetService
    def initialize(submission)
      @submission = submission
    end

    def was_last_target?
      return false if milestone_assignments.empty?

      if student.team.present?
        targets_passed?(milestone_assignments.team, student) &&
          students.all? do |s|
            targets_passed?(milestone_assignments.student, s)
          end
      else
        targets_passed?(milestone_assignments, student)
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

    def milestone_assignments
      course.assignments.milestone.merge(Target.live)
    end

    def targets_passed?(assignments, student)
      target_ids = assignments.pluck(:target_id)
      TimelineEvent
        .live
        .includes(:timeline_event_owners)
        .where(
          target_id: target_ids,
          timeline_event_owners: {
            student_id: student.id
          }
        )
        .where.not(passed_at: nil)
        .pluck(:target_id)
        .uniq
        .count == assignments.count
    end
  end
end
