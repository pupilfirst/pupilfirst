module Courses
  class AssignReviewerService
    def initialize(course)
      @course = course
    end

    def assign(faculty)
      raise 'Faculty must in same school as course' if faculty.school != @course.school

      return if faculty.courses.where(id: @course).exists?

      FacultyStartupEnrollment.transaction do
        FacultyCourseEnrollment.create!(
          safe_to_create: true,
          faculty: faculty,
          course: @course
        )
      end
    end
  end
end
