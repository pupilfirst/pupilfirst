module Founders
  class MarkAsDroppedOutService
    # @param student [Student] mark as dropped out
    def initialize(student, current_user)
      @student = student
      @current_user = current_user
    end

    def execute
      Founder.transaction do
        # Remove all coach enrollments.
        FacultyFounderEnrollment.where(founder: @student).destroy_all

        team = @student.team

        @student.update!(team_id: nil, dropped_out_at: Time.zone.now)

        team.destroy! if team && team.founders.blank?
      end
      create_audit_record(@student)
    end

    private

    def create_audit_record(student)
      AuditRecord.create!(
        audit_type: AuditRecord::TYPE_DROPOUT_STUDENT,
        school_id: @current_user.school_id,
        metadata: {
          user_id: @current_user.id,
          email: student.email
        }
      )
    end
  end
end
