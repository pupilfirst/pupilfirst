module Founders
  class MarkAsDroppedOutService
    # @param student [Student] mark as dropped out
    def initialize(student)
      @student = student
    end

    def execute
      Founder.transaction do
        if create_new_team?
          startup = Startup.create!(
            name: @student.name,
            level: @student.startup.level,
            dropped_out_at: Time.zone.now
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
      AuditRecord.create!(data: { 'type' => AuditRecord::TYPE_DROPOUT_STUDENT, 'log' => "Student email: #{student.email}; Course ID: #{student.course.id}" })
    end
  end
end
