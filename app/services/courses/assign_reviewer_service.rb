module Courses
  class AssignReviewerService
    def initialize(course)
      @course = course
    end

    def teams(faculty)
      raise 'Faculty must in same school as course' if faculty.school != @course.school

      return if faculty.courses.where(id: @course).exists?

      course_startups = Startup.joins(level: :course).where(levels: { courses: { id: @course.id } })

      FacultyStartupEnrollment.transaction do
        FacultyStartupEnrollment.where(faculty: faculty, startup: course_startups).each(&:destroy!)

        FacultyCourseEnrollment.create!(
          safe_to_create: true,
          faculty: faculty,
          course: @course
        )
      end
    end
  end
end
