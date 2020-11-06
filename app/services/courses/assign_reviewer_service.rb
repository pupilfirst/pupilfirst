module Courses
  class AssignReviewerService
    def initialize(course, notify: false)
      @course = course
      @notify = notify
    end

    def assign(faculty)
      raise 'Faculty must in same school as course' if faculty.school != @course.school

      return if faculty.courses.exists?(id: @course)

      enrollment = FacultyStartupEnrollment.transaction do
        FacultyCourseEnrollment.create!(
          safe_to_create: true,
          faculty: faculty,
          course: @course
        )
      end

      if @notify
        faculty.user.regenerate_login_token if faculty.user.login_token.blank?
        CoachMailer.course_enrollment(faculty, @course).deliver_later
      end

      enrollment
    end
  end
end
