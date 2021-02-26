module Students
  # This service handles all actions related to course completion by the given student.
  class AfterCourseCompletionService
    def initialize(student)
      @student = student
    end

    def execute
      Startups::IssueCertificateService.new(@student.startup).execute
    end
  end
end
