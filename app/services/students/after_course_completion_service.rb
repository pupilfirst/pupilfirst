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
      students.each do |student|
        if student.completed_at.blank?
          student.update!(completed_at: Time.zone.now)
        end

        Students::IssueCertificateService.new(student).issue
      end

      user = @student.user
      course = @student.course
      @notification_service.execute(course, :course_completed, user, course)
    end

    private

    def students
      @students ||= @student.team.present? ? @student.team.students : [@student]
    end
  end
end
