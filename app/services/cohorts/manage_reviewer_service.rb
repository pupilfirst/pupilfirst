module Cohorts
  class ManageReviewerService
    def initialize(course, cohorts, notify: false)
      @course = course
      @cohorts = cohorts
      @notify = notify
    end

    def assign(faculty)
      if faculty.school != @course.school
        raise 'Faculty must in same school as course'
      end

      old_cohorts_count = faculty.cohorts.where(course: @course).count

      FacultyCohortEnrollment.transaction do
        # Remove old assignments
        faculty
          .faculty_cohort_enrollments
          .joins(:cohort)
          .where(cohort: { course_id: @course })
          .where.not(cohort: @cohorts)
          .destroy_all

        @cohorts.map do |cohort|
          next if faculty.cohorts.exists?(id: cohort)
          FacultyCohortEnrollment.create!(faculty: faculty, cohort: cohort)
        end
      end

      if @notify && old_cohorts_count.zero?
        CoachMailer.course_enrollment(faculty, @course).deliver_later
      end

      faculty
    end
  end
end
