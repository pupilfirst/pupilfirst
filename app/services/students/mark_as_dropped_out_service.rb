module Students
  class MarkAsDroppedOutService
    # @param student [Student] mark as dropped out
    def initialize(student, current_user)
      @student = student
      @current_user = current_user
    end

    def execute
      Student.transaction do
        # Remove all coach enrollments.
        FacultyStudentEnrollment.where(student: @student).destroy_all

        team = @student.team

        @student.update!(team_id: nil, dropped_out_at: Time.zone.now)

        team.destroy! if team && team.students.blank?
      end
      create_audit_record(@student)
    end

    private

    def create_audit_record(student)
      AuditRecord.create!(
        audit_type: AuditRecord.audit_types[:dropout_student],
        school_id: @current_user.school_id,
        metadata: {
          user_id: @current_user.id,
          email: student.email
        }
      )
    end
  end
end
