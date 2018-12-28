module Courses
  class UnassignReviewerService
    def initialize(course)
      @course = course
    end

    def unassign(faculty)
      course_startups = Startup.joins(level: :course).where(levels: { courses: { id: @course.id } })

      Faculty.transaction do
        # Remove links to all teams in course, if any.
        faculty.faculty_startup_enrollments.where(startup: course_startups).each(&:destroy!)

        # Remove direct link, if any.
        faculty.faculty_course_enrollments.find_by(course_id: @course.id)&.destroy!
      end
    end
  end
end
