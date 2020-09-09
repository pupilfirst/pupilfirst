module Founders
  class MarkAsDroppedOutService
    # @param student [Student] mark as dropped out
    def initialize(student, current_user)
      @student = student
      @current_user = current_user
    end

    def execute
      Founder.transaction do
        if create_new_team?
          startup = Startup.create!(
            name: @student.name,
            level: @student.startup.level,
            dropped_out_at: Time.zone.now,
            tag_list: @student.startup.tag_list
          )

          # Mark the student as exited and set him into the new startup (which doesn't have any coach enrollments).
          @student.update!(startup: startup)
        else
          # Remove all coach enrollments.
          FacultyStartupEnrollment.where(startup: @student.startup).destroy_all

          # Mark the startup as exited.
          @student.startup.update!(dropped_out_at: Time.zone.now)
        end
        create_audit_record(@student)
      end
    end

    private

    def create_new_team?
      @create_new_team ||= @student.startup.founders.count > 1
    end

    def create_audit_record(student)
      AuditRecord.create!(audit_type: AuditRecord::TYPE_DROPOUT_STUDENT, school_id: @current_user.school_id, metadata: { user_id: @current_user.id, email: student.email })
    end
  end
end
