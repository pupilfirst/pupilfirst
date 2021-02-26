module Students
  # This service handles all actions related to course completion by the given student.
  class AfterCourseCompletionService
    def initialize(
      student,
      notification_service: Developers::NotificationService.new
    )
      @student = student
      @notification_service = notification_service
    end

    def execute
      Startups::IssueCertificateService.new(@student.startup).execute

      user = @student.user
      course = @student.course
      @notification_service.execute(
        course,
        :course_completed,
        user,
        course
      )
    end
  end
end
