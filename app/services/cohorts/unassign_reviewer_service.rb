module Cohorts
  class UnassignReviewerService
    def initialize(course)
      @course = course
    end

    def unassign(faculty)
      Faculty.transaction do
        students_in_cohorts = Founder.where(cohorts: @course.cohorts)

        # Remove links to all students in course, if any.
        faculty
          .faculty_founder_enrollments
          .where(founder: students_in_cohorts)
          .each(&:destroy!)

        faculty
          .faculty_cohort_enrollments
          .where(cohort: @course.cohorts)
          .each(&:destroy!)
      end
    end
  end
end
