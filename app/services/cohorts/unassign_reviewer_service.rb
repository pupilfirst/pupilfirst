module Cohorts
  class UnassignReviewerService
    def initialize(cohorts)
      @cohorts = cohorts
    end

    def unassign(faculty)
      Faculty.transaction do
        students_in_cohorts = Founder.where(cohorts: @cohorts)

        # Remove links to all students in course, if any.
        faculty
          .faculty_founder_enrollments
          .where(founder: students_in_cohorts)
          .each(&:destroy!)

        faculty
          .faculty_cohort_enrollments
          .where(cohort: @cohorts)
          .each { |enrollment| enrollment.destroy! }
      end
    end
  end
end
