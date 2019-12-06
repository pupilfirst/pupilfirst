module Founders
  class MarkAsExitedService
    # @param student [Student] mark as dropped out
    def initialize(student)
      @student = student
    end

    def execute
      Founder.transaction do
        if create_new_team?
          startup = Startup.create!(
            name: @student.name,
            level: @student.startup.level
          )

          # Mark the student as exited and set him into the new startup (which doesn't have any coach enrollments).
          @student.update!(startup: startup, exited_on: Date.today)
        else
          # Remove all coach enrollments.
          FacultyStartupEnrollment.where(startup: @student.startup).destroy_all

          # Mark the student as exited.
          @student.update!(exited_on: Date.today)
        end
      end
    end

    private

    def create_new_team?
      @create_new_team ||= @student.startup.founders.count > 1
    end
  end
end
