module Cohorts
  class AssignReviewerService
    def initialize(cohort, notify: false)
      @cohort = cohort
      @notify = notify
    end

    def assign(faculty)
      if faculty.school != @cohort.school
        raise 'Faculty must in same school as course'
      end

      return if faculty.cohorts.exists?(id: @cohort)

      enrollment =
        FacultyCohortEnrollment.transaction do
          FacultyCohortEnrollment.create!(faculty: faculty, cohort: @cohort)
        end

      if @notify
        faculty.user.regenerate_login_token
        CoachMailer.course_enrollment(faculty, @course).deliver_later
      end

      enrollment
    end
  end
end
